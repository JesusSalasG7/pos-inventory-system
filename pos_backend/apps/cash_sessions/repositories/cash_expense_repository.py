"""Acceso a datos de los egresos de caja."""

from decimal import Decimal

from django.db.models import QuerySet, Sum

from apps.auth.models import User
from apps.cash_sessions.models import CashExpense, CashSession
from core.enums import Currency


def create(
    *, cash_session: CashSession, reason: str, amount: Decimal, currency: Currency, created_by: User
) -> CashExpense:
    """Inserta un egreso de caja."""
    return CashExpense.objects.create(
        cash_session=cash_session,
        reason=reason,
        amount=amount,
        currency=currency,
        created_by=created_by,
    )


def list_by_session(cash_session_id: int) -> QuerySet[CashExpense]:
    """Lista los egresos de una caja, del más reciente al más antiguo."""
    return CashExpense.objects.filter(cash_session_id=cash_session_id).order_by(
        "-created_at", "-id"
    )


def totals_by_currency(cash_session_id: int) -> dict[str, Decimal]:
    """Suma los egresos de una caja agrupados por moneda."""
    rows = (
        CashExpense.objects.filter(cash_session_id=cash_session_id)
        .values("currency")
        .annotate(total=Sum("amount"))
    )
    return {row["currency"]: row["total"] for row in rows}
