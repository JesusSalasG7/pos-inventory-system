"""Arqueo de caja: cuánto debería haber frente a lo contado."""

from dataclasses import dataclass
from decimal import Decimal

from apps.cash_sessions.models import CashSession
from apps.cash_sessions.repositories import cash_expense_repository
from core.enums import Currency, PaymentMethod
from core.money import quantize_money, ves_to_usd

CASH_METHODS = (PaymentMethod.CASH_USD, PaymentMethod.CASH_VES)
ZERO = Decimal("0.00")


@dataclass(frozen=True)
class CashCountSummary:
    """Resultado del arqueo de una caja."""

    opening_float: Decimal
    cash_sales_usd: Decimal
    cash_sales_ves: Decimal
    electronic_sales_usd: Decimal
    electronic_sales_ves: Decimal
    expenses_usd: Decimal
    expenses_ves: Decimal
    expected_cash_usd: Decimal
    expected_cash_ves: Decimal


def build_summary(session: CashSession) -> CashCountSummary:
    """Calcula el efectivo esperado en la caja.

    Efectivo esperado USD = fondo inicial + ventas en efectivo USD − egresos USD.
    Efectivo esperado VES = ventas en efectivo VES − egresos VES.
    POS_CARD y MOBILE_PAYMENT se informan aparte: no son efectivo en gaveta.

    El acceso del usuario a la caja lo valida quien llama
    (`cash_session_service.get_session`).
    """
    # Import local: sale_service depende a su vez de los services de esta app.
    from apps.sales.services import sale_service

    totals: dict[tuple[bool, str], Decimal] = {}
    for (method, currency), amount in sale_service.get_payment_totals_for_session(
        session.pk
    ).items():
        key = (method in CASH_METHODS, currency)
        totals[key] = totals.get(key, ZERO) + amount

    expenses = cash_expense_repository.totals_by_currency(session.pk)
    cash_sales_usd = totals.get((True, Currency.USD), ZERO)
    cash_sales_ves = totals.get((True, Currency.VES), ZERO)
    expenses_usd = expenses.get(Currency.USD, ZERO)
    expenses_ves = expenses.get(Currency.VES, ZERO)

    return CashCountSummary(
        opening_float=session.opening_float,
        cash_sales_usd=cash_sales_usd,
        cash_sales_ves=cash_sales_ves,
        electronic_sales_usd=totals.get((False, Currency.USD), ZERO),
        electronic_sales_ves=totals.get((False, Currency.VES), ZERO),
        expenses_usd=expenses_usd,
        expenses_ves=expenses_ves,
        expected_cash_usd=session.opening_float + cash_sales_usd - expenses_usd,
        expected_cash_ves=cash_sales_ves - expenses_ves,
    )


def calculate_difference(
    session: CashSession,
    *,
    counted_amount_usd: Decimal,
    counted_amount_ves: Decimal,
    usd_to_ves_rate: Decimal,
) -> Decimal:
    """Devuelve la diferencia del arqueo expresada en USD.

    Diferencia = (contado USD − esperado USD)
               + (contado VES − esperado VES) convertido a USD con la tasa activa.
    Positiva significa sobrante; negativa, faltante.
    """
    summary = build_summary(session)
    difference_usd = counted_amount_usd - summary.expected_cash_usd
    difference_ves = counted_amount_ves - summary.expected_cash_ves
    return quantize_money(difference_usd + ves_to_usd(difference_ves, usd_to_ves_rate))
