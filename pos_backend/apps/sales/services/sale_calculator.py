"""Cálculos puros de una venta: sin ORM, sin settings y sin efectos secundarios."""

from collections.abc import Iterable
from decimal import Decimal

from apps.sales.domain.dtos import LineTotal, PaymentInput, PricedLine, SaleTotals
from core.enums import Currency
from core.exceptions import PaymentMismatchError
from core.money import quantize_money, usd_to_ves, ves_to_usd

DEFAULT_PAYMENT_TOLERANCE_USD = Decimal("0.01")


def calculate_line_subtotal(quantity: Decimal, unit_price_usd: Decimal) -> Decimal:
    """Subtotal de una línea: cantidad × precio unitario, redondeado a 2 decimales."""
    return quantize_money(quantity * unit_price_usd)


def calculate_totals(lines: Iterable[PricedLine], usd_to_ves_rate: Decimal) -> SaleTotals:
    """Calcula los subtotales por línea y los totales en USD y VES.

    El total en USD es la suma de los subtotales ya redondeados, de modo que la
    cabecera siempre coincide con sus líneas. El total en VES se obtiene del
    total en USD con la tasa congelada de la venta.
    """
    line_totals = tuple(
        LineTotal(
            product_id=line.product_id,
            quantity=line.quantity,
            unit_price_usd=line.unit_price_usd,
            subtotal_usd=calculate_line_subtotal(line.quantity, line.unit_price_usd),
        )
        for line in lines
    )
    total_usd = quantize_money(sum((line.subtotal_usd for line in line_totals), Decimal("0")))
    return SaleTotals(
        lines=line_totals,
        total_usd=total_usd,
        total_ves=usd_to_ves(total_usd, usd_to_ves_rate),
    )


def payments_total_usd(payments: Iterable[PaymentInput], usd_to_ves_rate: Decimal) -> Decimal:
    """Suma los pagos mixtos expresados en USD.

    Los pagos en VES se suman primero entre sí y se convierten una sola vez,
    para no acumular un error de redondeo por cada pago.
    """
    paid_usd = Decimal("0")
    paid_ves = Decimal("0")
    for payment in payments:
        if payment.currency == Currency.USD:
            paid_usd += payment.amount
        else:
            paid_ves += payment.amount
    return quantize_money(paid_usd + ves_to_usd(paid_ves, usd_to_ves_rate))


def validate_payments(
    total_usd: Decimal,
    payments: Iterable[PaymentInput],
    usd_to_ves_rate: Decimal,
    tolerance_usd: Decimal = DEFAULT_PAYMENT_TOLERANCE_USD,
) -> Decimal:
    """Valida que los pagos cuadren con el total dentro de la tolerancia.

    Devuelve lo pagado en USD. Lanza PaymentMismatchError tanto si falta como
    si sobra dinero: el vuelto no se modela en esta fase.
    """
    paid_usd = payments_total_usd(payments, usd_to_ves_rate)
    difference = paid_usd - quantize_money(total_usd)
    if abs(difference) > tolerance_usd:
        raise PaymentMismatchError(
            meta={
                "expected_usd": str(quantize_money(total_usd)),
                "paid_usd": str(paid_usd),
                "difference_usd": str(difference),
                "tolerance_usd": str(tolerance_usd),
            }
        )
    return paid_usd
