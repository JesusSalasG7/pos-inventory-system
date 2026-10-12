"""Fórmulas de las estadísticas. Funciones puras, sin base de datos.

Son las únicas definiciones de cada métrica: todo el módulo las usa.
"""

from collections.abc import Sequence
from datetime import date, timedelta
from decimal import ROUND_HALF_UP, Decimal

from apps.statistics.domain.dtos import Period
from apps.statistics.domain.enums import Quadrant

ZERO = Decimal("0.00")
HUNDRED = Decimal(100)
PERCENT_QUANTUM = Decimal("0.01")
DAYS_QUANTUM = Decimal("0.1")
DEFAULT_PERIOD_DAYS = 30


def quantize_percent(value: Decimal) -> Decimal:
    """Redondea un porcentaje a 2 decimales (mitad hacia arriba)."""
    return value.quantize(PERCENT_QUANTUM, rounding=ROUND_HALF_UP)


def margin_percent(profit: Decimal, revenue: Decimal) -> Decimal:
    """Margen % = ganancia ÷ ingresos × 100; 0 si no hay ingresos."""
    if revenue == 0:
        return ZERO
    return quantize_percent(profit / revenue * HUNDRED)


def average_ticket(revenue: Decimal, sales_count: int) -> Decimal:
    """Ticket promedio = ingresos ÷ número de ventas; 0 si no hay ventas."""
    if sales_count == 0:
        return ZERO
    return (revenue / sales_count).quantize(PERCENT_QUANTUM, rounding=ROUND_HALF_UP)


def change_percent(current: Decimal | int, previous: Decimal | int) -> Decimal | None:
    """Variación % = (actual − anterior) ÷ |anterior| × 100; nula si el anterior es 0.

    Se divide entre el valor absoluto para que, con una ganancia anterior
    negativa, mejorar siga dando una variación positiva.
    """
    if previous == 0:
        return None
    return quantize_percent((Decimal(current) - Decimal(previous)) / abs(Decimal(previous)) * 100)


def resolve_period(date_from: date | None, date_to: date | None, *, today: date) -> Period:
    """Completa el período: sin `date_to`, hasta hoy; sin `date_from`, 30 días en total."""
    date_to = date_to or today
    date_from = date_from or date_to - timedelta(days=DEFAULT_PERIOD_DAYS - 1)
    return Period(date_from=date_from, date_to=date_to)


def previous_period(period: Period) -> Period:
    """Período de la misma duración que termina el día antes de que empiece `period`."""
    days = (period.date_to - period.date_from).days + 1
    return Period(
        date_from=period.date_from - timedelta(days=days),
        date_to=period.date_from - timedelta(days=1),
    )


def median(values: Sequence[Decimal]) -> Decimal:
    """Mediana; con cantidad par, el promedio de los dos valores centrales. Vacío: 0."""
    if not values:
        return ZERO
    ordered = sorted(values)
    middle = len(ordered) // 2
    if len(ordered) % 2:
        return ordered[middle]
    return (ordered[middle - 1] + ordered[middle]) / 2


def quadrant(
    units: Decimal, margin: Decimal, *, median_units: Decimal, median_margin: Decimal
) -> Quadrant:
    """Cuadrante de un producto. Igualar la mediana cuenta como estar por encima."""
    high_volume = units >= median_units
    high_margin = margin >= median_margin
    if high_volume:
        return Quadrant.STAR if high_margin else Quadrant.VOLUME_DRIVER
    return Quadrant.PROFITABLE_NICHE if high_margin else Quadrant.REVIEW


def days_left(stock: Decimal, daily_rate: Decimal) -> Decimal:
    """Días restantes = stock ÷ ritmo diario, con 1 decimal. Exige un ritmo positivo."""
    return (stock / daily_rate).quantize(DAYS_QUANTUM, rounding=ROUND_HALF_UP)
