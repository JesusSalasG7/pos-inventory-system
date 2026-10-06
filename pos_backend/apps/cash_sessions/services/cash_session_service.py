"""Ciclo de vida de la caja: apertura, egresos y cierre."""

from decimal import Decimal

from django.db import IntegrityError, transaction
from django.db.models import QuerySet
from django.utils import timezone

from apps.auth.models import User
from apps.cash_sessions.models import CashExpense, CashSession
from apps.cash_sessions.repositories import cash_expense_repository, cash_session_repository
from apps.cash_sessions.services import cash_count_service
from apps.exchange_rate.services import exchange_rate_service
from core.branch_scope import can_access_branch, has_all_branches_access, resolve_branch
from core.enums import Currency, Role
from core.exceptions import BranchAccessDeniedError, DomainError, NoOpenSessionError, NotFoundError

OPEN_SESSION_CONSTRAINT = "unique_open_cash_session_per_user"


def open_session(*, user: User, branch: str | None, opening_float: Decimal) -> CashSession:
    """Abre una caja para el usuario en la sucursal.

    Pasos:
    1. Resolver la sucursal y validar el acceso con `resolve_branch`.
    2. Validar que `opening_float` no sea negativo.
    3. Crear la caja. Si el usuario ya tiene una abierta se lanza un DomainError
       `session_already_open` (409). La restricción única parcial de la BD cubre
       además la carrera entre dos aperturas simultáneas.
    """
    resolved_branch = resolve_branch(user, branch)
    _require_non_negative(opening_float, "opening_float")

    existing = cash_session_repository.get_open_by_user(user.pk)
    if existing is not None:
        raise _already_open(existing)

    try:
        # El savepoint evita que el IntegrityError rompa una transacción exterior.
        with transaction.atomic():
            return cash_session_repository.create(
                user=user, branch=resolved_branch, opening_float=opening_float
            )
    except IntegrityError as exc:
        if OPEN_SESSION_CONSTRAINT not in str(exc):
            raise
        raise _already_open(cash_session_repository.get_open_by_user(user.pk)) from exc


def get_open_session(user: User, branch: str | None = None, *, lock: bool = False) -> CashSession:
    """Devuelve la caja abierta del usuario.

    Lanza NoOpenSessionError (409) si no tiene ninguna o si la que tiene
    pertenece a otra sucursal distinta de `branch`. Es el punto de entrada de
    `sale_service` para verificar la caja antes de facturar.

    Con `lock` bloquea la fila dentro de la transacción en curso: mientras se
    registra una venta la caja no puede cerrarse, y el arqueo del cierre nunca
    se calcula con una venta a medias.
    """
    session = (
        cash_session_repository.get_open_by_user(user.pk, lock=True)
        if lock
        else cash_session_repository.get_open_by_user(user.pk)
    )
    if session is None:
        raise NoOpenSessionError()
    if branch is not None and session.branch_id != branch:
        raise NoOpenSessionError(
            meta={"requested_branch": branch, "open_session_branch": session.branch_id}
        )
    return session


def has_open_session(user: User) -> bool:
    """Indica si el usuario tiene una caja abierta. Lo consulta `user_service`."""
    return cash_session_repository.get_open_by_user(user.pk) is not None


def has_open_sessions_in_branch(branch: str) -> bool:
    """Indica si la sucursal tiene alguna caja abierta. Lo consulta `branch_service`."""
    return cash_session_repository.list_filtered(branch=branch, only_open=True).exists()


def get_session(session_id: int, user: User) -> CashSession:
    """Devuelve la caja validando que el usuario tenga acceso a su sucursal."""
    session = cash_session_repository.get_by_id(session_id)
    if session is None:
        raise _not_found(session_id)
    _require_branch_access(session, user)
    return session


def close_session(
    *, session_id: int, user: User, counted_amount_usd: Decimal, counted_amount_ves: Decimal
) -> CashSession:
    """Cierra la caja guardando el arqueo.

    Pasos, dentro de `transaction.atomic()`:
    1. Bloquear la caja con `select_for_update` y validar que siga abierta
       (si no, DomainError `session_already_closed`, 409).
    2. Validar que el usuario sea el dueño de la caja o un MANAGER con acceso
       a la sucursal.
    3. Calcular `difference_usd` con `cash_count_service.calculate_difference`
       usando la tasa activa (sin tasa registrada no se puede cerrar).
    4. Guardar los montos contados, la diferencia y `closed_at`.
    """
    _require_non_negative(counted_amount_usd, "counted_amount_usd")
    _require_non_negative(counted_amount_ves, "counted_amount_ves")

    with transaction.atomic():
        session = cash_session_repository.lock_by_id(session_id)
        if session is None:
            raise _not_found(session_id)
        _require_owner_or_manager(session, user)
        _require_open(session)

        rate = exchange_rate_service.get_active_rate()
        difference_usd = cash_count_service.calculate_difference(
            session,
            counted_amount_usd=counted_amount_usd,
            counted_amount_ves=counted_amount_ves,
            usd_to_ves_rate=rate.usd_to_ves_rate,
        )
        return cash_session_repository.close(
            session,
            closed_at=timezone.now(),
            counted_amount_usd=counted_amount_usd,
            counted_amount_ves=counted_amount_ves,
            difference_usd=difference_usd,
        )


def register_expense(
    *, session_id: int, user: User, reason: str, amount: Decimal, currency: Currency
) -> CashExpense:
    """Registra un egreso de efectivo en una caja abierta.

    Pasos, dentro de `transaction.atomic()`:
    1. Bloquear la caja y validar que exista, que el usuario sea su dueño o un
       MANAGER con acceso, y que siga abierta. El bloqueo impide registrar un
       egreso mientras otra petición la está cerrando.
    2. Validar que `amount` sea mayor que cero y que haya un motivo.
    3. Insertar el egreso.
    """
    reason = reason.strip()
    if not reason:
        raise DomainError(
            "El motivo del egreso es obligatorio.", code="invalid_reason", status_code=422
        )
    if amount <= 0:
        raise DomainError(
            "El monto del egreso debe ser mayor que cero.",
            code="invalid_amount",
            status_code=422,
            meta={"amount": str(amount)},
        )

    with transaction.atomic():
        session = cash_session_repository.lock_by_id(session_id)
        if session is None:
            raise _not_found(session_id)
        _require_owner_or_manager(session, user)
        _require_open(session)
        return cash_expense_repository.create(
            cash_session=session, reason=reason, amount=amount, currency=currency, created_by=user
        )


def list_expenses(session_id: int, user: User) -> QuerySet[CashExpense]:
    """Lista los egresos de la caja, validando el acceso a su sucursal."""
    session = get_session(session_id, user)
    return cash_expense_repository.list_by_session(session.pk)


def list_sessions(
    user: User, *, branch: str | None = None, only_open: bool = False
) -> QuerySet[CashSession]:
    """Lista las cajas de la sucursal resuelta con `resolve_branch`.

    Un MANAGER con acceso a todas las sucursales que no indica ninguna recibe
    las cajas de todas.
    """
    if branch is None and has_all_branches_access(user):
        resolved_branch = None
    else:
        resolved_branch = resolve_branch(user, branch)
    return cash_session_repository.list_filtered(branch=resolved_branch, only_open=only_open)


def _require_branch_access(session: CashSession, user: User) -> None:
    if not can_access_branch(user, session.branch_id):
        raise BranchAccessDeniedError(
            meta={
                "requested_branch": session.branch_id,
                "assigned_branch": user.assigned_branch_id,
            }
        )


def _require_owner_or_manager(session: CashSession, user: User) -> None:
    _require_branch_access(session, user)
    if session.user_id != user.pk and user.role != Role.MANAGER:
        raise DomainError(
            "Solo el dueño de la caja o un gerente pueden operar sobre ella.",
            code="not_session_owner",
            status_code=403,
            meta={"cash_session_id": session.pk},
        )


def _require_open(session: CashSession) -> None:
    if not session.is_open:
        raise DomainError(
            "La caja ya está cerrada.",
            code="session_already_closed",
            status_code=409,
            meta={"cash_session_id": session.pk, "closed_at": session.closed_at.isoformat()},
        )


def _require_non_negative(amount: Decimal, field: str) -> None:
    if amount < 0:
        raise DomainError(
            "El monto no puede ser negativo.",
            code="invalid_amount",
            status_code=422,
            meta={"field": field, "amount": str(amount)},
        )


def _not_found(session_id: int) -> NotFoundError:
    return NotFoundError(
        "La caja no existe.", code="cash_session_not_found", meta={"cash_session_id": session_id}
    )


def _already_open(session: CashSession | None) -> DomainError:
    meta = {"cash_session_id": session.pk, "branch": session.branch_id} if session else {}
    return DomainError(
        "El usuario ya tiene una caja abierta.",
        code="session_already_open",
        status_code=409,
        meta=meta,
    )
