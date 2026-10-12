"""Deudas de clientes: apertura al vender a crédito y cobro de abonos.

Las deudas se guardan y se descuentan en USD. Un abono en bolívares se pasa a
USD con la tasa del BCV del día del abono (`bcv_rate_service.get_cost_rate`),
no con la tasa de la venta ni con una tasa manual.
"""

from datetime import date
from decimal import Decimal

from django.conf import settings
from django.db import transaction
from django.db.models import QuerySet
from django.utils import timezone

from apps.auth.models import User
from apps.cash_sessions.services import cash_session_service
from apps.credits.domain.dtos import CreditPaymentInput
from apps.credits.models import Credit, CreditPayment
from apps.credits.repositories import credit_repository
from apps.credits.services import customer_service
from apps.exchange_rate.services import bcv_rate_service
from core.branch_scope import can_access_branch
from core.enums import Currency, PaymentMethod
from core.exceptions import BranchAccessDeniedError, DomainError
from core.money import quantize_money, usd_to_ves, ves_to_usd
from core.payment_rules import METHOD_CURRENCY

ZERO = Decimal("0.00")


class CreditStatus:
    """Filtros del listado de deudas."""

    PENDING = "PENDING"
    OVERDUE = "OVERDUE"
    PAID = "PAID"
    ALL = "ALL"

    choices = ((PENDING, "Pendientes"), (OVERDUE, "Vencidas"), (PAID, "Saldadas"), (ALL, "Todas"))


def open_credit(
    *, sale_id: int, customer_id: int, branch: str, amount_usd: Decimal, due_date: date
) -> Credit:
    """Registra la deuda de una venta a crédito.

    La llama `sale_service.create_sale` dentro de su transacción: la venta y
    su deuda se guardan juntas o ninguna.
    """
    return credit_repository.create_credit(
        sale_id=sale_id,
        customer_id=customer_id,
        branch=branch,
        amount_usd=quantize_money(amount_usd),
        due_date=due_date,
    )


def list_credits(
    user: User,
    *,
    branch: str | None = None,
    customer_id: int | None = None,
    status: str = CreditStatus.PENDING,
) -> QuerySet[Credit]:
    """Deudas de la sucursal, de la que vence antes a la que vence después.

    `PENDING` trae las que tienen saldo (vencidas o no); `OVERDUE`, solo las
    vencidas; `PAID`, las saldadas. La app las usa para programar los avisos
    de vencimiento.
    """
    return credit_repository.list_credits(
        branch=customer_service.scope_branch(user, branch),
        customer_id=customer_id,
        only_pending=status in (CreditStatus.PENDING, CreditStatus.OVERDUE),
        only_paid=status == CreditStatus.PAID,
        due_before=timezone.localdate() if status == CreditStatus.OVERDUE else None,
    )


def get_payment_rate() -> Decimal | None:
    """Tasa del BCV con la que se cobran hoy los abonos en bolívares, o None."""
    return bcv_rate_service.get_cost_rate()


def register_payment(data: CreditPaymentInput, user: User) -> CreditPayment:
    """Cobra un abono del cliente en la caja abierta del usuario.

    Flujo:

    1. Validar el pago: monto positivo, moneda acorde al método, referencia en
       los métodos electrónicos. `CREDIT` no vale: una deuda no se paga con otra.
    2. Pasar el monto a USD. Los bolívares se convierten con la tasa del BCV
       del día; sin ella no se puede cobrar en bolívares (`bcv_rate_unavailable`).
    3. Dentro de `transaction.atomic()`:
       a. Bloquear la caja abierta del usuario (el abono entra en su arqueo).
       b. Bloquear las deudas con saldo del cliente en la sucursal de la caja.
       c. Si el abono supera lo que debe (más la tolerancia), rechazarlo
          (`credit_overpayment`). Si cubre el saldo dentro de la tolerancia,
          lo salda por completo: el redondeo de la conversión no deja céntimos.
       d. Repartir el abono entre las deudas, la que vence antes primero, y
          marcar como saldadas las que quedan en cero.
    """
    method = PaymentMethod(data.method)
    currency = Currency(data.currency)
    amount = quantize_money(data.amount)
    reference = data.approval_reference.strip()
    _validate_payment(method, currency, amount)

    rate = get_payment_rate()
    if rate is None:
        if currency == Currency.VES:
            raise DomainError(
                "No hay tasa del BCV para cobrar en bolívares. Intente de nuevo más tarde.",
                code="bcv_rate_unavailable",
                status_code=503,
            )
        rate = Decimal("0")
    amount_usd = amount if currency == Currency.USD else ves_to_usd(amount, rate)

    customer_service.get_customer(data.customer_id, user)
    tolerance = settings.PAYMENT_TOLERANCE_USD

    with transaction.atomic():
        session = cash_session_service.get_open_session(user, lock=True)
        branch = session.branch_id
        if not can_access_branch(user, branch):
            raise BranchAccessDeniedError(
                meta={"requested_branch": branch, "assigned_branch": user.assigned_branch_id}
            )
        credits = credit_repository.lock_pending_by_customer(data.customer_id, branch)
        balance = sum((credit.balance_usd for credit in credits), ZERO)
        if balance <= 0:
            raise DomainError(
                "El cliente no tiene deudas pendientes en esta tienda.",
                code="no_pending_credit",
                status_code=409,
                meta={"customer_id": data.customer_id, "branch": branch},
            )
        if amount_usd - balance > tolerance:
            raise DomainError(
                "El abono supera lo que debe el cliente.",
                code="credit_overpayment",
                status_code=422,
                meta={
                    "balance_usd": str(balance),
                    "balance_ves": str(usd_to_ves(balance, rate)) if rate > 0 else None,
                    "paid_usd": str(amount_usd),
                },
            )
        applied = balance if balance - amount_usd <= tolerance else amount_usd

        payment = credit_repository.create_payment(
            customer_id=data.customer_id,
            cash_session=session,
            user=user,
            method=method,
            currency=currency,
            amount=amount,
            approval_reference=reference,
            usd_to_ves_rate=rate,
            amount_usd=applied,
        )
        now = timezone.now()
        allocations: list[tuple[int, Decimal]] = []
        remaining = applied
        for credit in credits:
            if remaining <= 0:
                break
            portion = min(credit.balance_usd, remaining)
            remaining -= portion
            credit_repository.apply_payment(
                credit, portion, paid_at=now if portion == credit.balance_usd else None
            )
            allocations.append((credit.pk, portion))
        credit_repository.bulk_create_allocations(payment, allocations)

    return credit_repository.get_payment(payment.pk)


def list_payments(
    customer_id: int, user: User, *, branch: str | None = None
) -> QuerySet[CreditPayment]:
    """Abonos del cliente en la sucursal, del más reciente al más antiguo."""
    customer_service.get_customer(customer_id, user, branch=branch)
    return credit_repository.list_payments(
        customer_id=customer_id, branch=customer_service.scope_branch(user, branch)
    )


def get_payment_totals_for_session(cash_session_id: int) -> dict[tuple[str, str], Decimal]:
    """Abonos cobrados en una caja por (método, moneda).

    Lo consumen el arqueo (`cash_count_service`) y el resumen de la caja
    (`sales_report_service`).
    """
    return credit_repository.payment_totals_by_session(cash_session_id)


def _validate_payment(method: PaymentMethod, currency: Currency, amount: Decimal) -> None:
    if method == PaymentMethod.CREDIT:
        raise _invalid_payment("Un abono no puede pagarse a crédito.", method=str(method))
    if amount <= 0:
        raise _invalid_payment("El monto del abono debe ser mayor que cero.")
    if METHOD_CURRENCY[method] != currency:
        raise _invalid_payment(
            "La moneda no corresponde al método de pago.",
            method=str(method),
            currency=str(currency),
        )


def _invalid_payment(detail: str, **meta: str) -> DomainError:
    return DomainError(detail, code="invalid_payment", status_code=422, meta=meta)
