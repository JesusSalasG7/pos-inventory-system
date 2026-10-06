"""Acceso a datos de los turnos de caja."""

from datetime import datetime
from decimal import Decimal

from django.db.models import QuerySet

from apps.auth.models import User
from apps.cash_sessions.models import CashSession


def get_open_by_user(user_id: int, *, lock: bool = False) -> CashSession | None:
    """Devuelve la caja abierta del usuario (`closed_at IS NULL`), o None.

    Con `lock` la bloquea con `select_for_update`; requiere `transaction.atomic()`.
    """
    queryset = CashSession.objects.filter(user_id=user_id, closed_at__isnull=True)
    if lock:
        queryset = queryset.select_for_update()
    return queryset.first()


def get_by_id(session_id: int) -> CashSession | None:
    """Devuelve la caja o None si no existe."""
    return CashSession.objects.filter(pk=session_id).first()


def lock_by_id(session_id: int) -> CashSession | None:
    """Devuelve la caja bloqueada con `select_for_update` para cerrarla.

    Debe llamarse dentro de `transaction.atomic()`.
    """
    return CashSession.objects.select_for_update().filter(pk=session_id).first()


def create(*, user: User, branch: str, opening_float: Decimal) -> CashSession:
    """Inserta una caja abierta."""
    return CashSession.objects.create(user=user, branch_id=branch, opening_float=opening_float)


def close(
    session: CashSession,
    *,
    closed_at: datetime,
    counted_amount_usd: Decimal,
    counted_amount_ves: Decimal,
    difference_usd: Decimal,
) -> CashSession:
    """Guarda el arqueo y marca la caja como cerrada."""
    session.closed_at = closed_at
    session.counted_amount_usd = counted_amount_usd
    session.counted_amount_ves = counted_amount_ves
    session.difference_usd = difference_usd
    session.save(
        update_fields=[
            "closed_at",
            "counted_amount_usd",
            "counted_amount_ves",
            "difference_usd",
            "updated_at",
        ]
    )
    return session


def list_filtered(
    *, branch: str | None = None, user_id: int | None = None, only_open: bool = False
) -> QuerySet[CashSession]:
    """Lista cajas filtradas, de la más reciente a la más antigua."""
    queryset = CashSession.objects.order_by("-opened_at", "-id")
    if branch is not None:
        queryset = queryset.filter(branch_id=branch)
    if user_id is not None:
        queryset = queryset.filter(user_id=user_id)
    if only_open:
        queryset = queryset.filter(closed_at__isnull=True)
    return queryset
