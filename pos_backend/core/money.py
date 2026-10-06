"""Utilidades puras para dinero, tasas y cantidades.

Todo se opera con Decimal; los float se rechazan de forma explícita porque
introducen errores de representación binaria.
"""

from decimal import ROUND_HALF_UP, Decimal

MONEY_QUANTUM = Decimal("0.01")
RATE_QUANTUM = Decimal("0.0001")
QUANTITY_QUANTUM = Decimal("0.001")

type Number = Decimal | int | str


def to_decimal(value: Number) -> Decimal:
    """Convierte a Decimal; rechaza float y bool."""
    if isinstance(value, Decimal):
        return value
    if isinstance(value, bool) or not isinstance(value, int | str):
        raise TypeError(f"Se esperaba Decimal, int o str; se recibió {type(value).__name__}.")
    return Decimal(value)


def quantize_money(amount: Number) -> Decimal:
    """Redondea un importe a 2 decimales (mitad hacia arriba)."""
    return to_decimal(amount).quantize(MONEY_QUANTUM, rounding=ROUND_HALF_UP)


def quantize_rate(rate: Number) -> Decimal:
    """Redondea una tasa de cambio a 4 decimales."""
    return to_decimal(rate).quantize(RATE_QUANTUM, rounding=ROUND_HALF_UP)


def quantize_quantity(quantity: Number) -> Decimal:
    """Redondea una cantidad de stock a 3 decimales."""
    return to_decimal(quantity).quantize(QUANTITY_QUANTUM, rounding=ROUND_HALF_UP)


def usd_to_ves(amount_usd: Number, usd_to_ves_rate: Number) -> Decimal:
    """Convierte USD a VES con la tasa indicada (VES por 1 USD)."""
    return quantize_money(to_decimal(amount_usd) * _positive_rate(usd_to_ves_rate))


def ves_to_usd(amount_ves: Number, usd_to_ves_rate: Number) -> Decimal:
    """Convierte VES a USD con la tasa indicada (VES por 1 USD)."""
    return quantize_money(to_decimal(amount_ves) / _positive_rate(usd_to_ves_rate))


def _positive_rate(rate: Number) -> Decimal:
    value = to_decimal(rate)
    if value <= 0:
        raise ValueError("La tasa de cambio debe ser mayor que cero.")
    return value
