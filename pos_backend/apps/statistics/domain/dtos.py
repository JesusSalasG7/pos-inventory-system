"""DTOs inmutables de entrada y resultado de las estadísticas.

Los importes van en USD. Los márgenes y las variaciones son porcentajes con
2 decimales; la variación del margen son puntos porcentuales.
"""

from dataclasses import dataclass
from datetime import date
from decimal import Decimal


@dataclass(frozen=True)
class StatisticsFilters:
    """Filtros globales. `branch` ya viene resuelta; sin fechas, los últimos 30 días."""

    branch: str
    date_from: date | None = None
    date_to: date | None = None
    category_id: int | None = None
    subcategory_id: int | None = None


@dataclass(frozen=True)
class Period:
    """Rango de días, ambos incluidos, en la zona horaria de la tienda."""

    date_from: date
    date_to: date


@dataclass(frozen=True)
class Kpis:
    revenue: Decimal
    profit: Decimal
    margin: Decimal
    units: Decimal
    sales_count: int
    average_ticket: Decimal


@dataclass(frozen=True)
class KpiChanges:
    """Variación de cada métrica contra el período anterior; nula si no es calculable."""

    revenue: Decimal | None
    profit: Decimal | None
    # Diferencia en puntos porcentuales, no en porcentaje.
    margin: Decimal | None
    units: Decimal | None
    sales_count: Decimal | None
    average_ticket: Decimal | None


@dataclass(frozen=True)
class Summary:
    period: Period
    previous_period: Period
    current: Kpis
    previous: Kpis
    change: KpiChanges


@dataclass(frozen=True)
class GroupPerformance:
    """Rendimiento de una categoría o subcategoría. `id` nulo: sin subcategoría."""

    id: int | None
    name: str
    units: Decimal
    revenue: Decimal
    profit: Decimal
    margin: Decimal


@dataclass(frozen=True)
class GroupReport:
    level: str
    # Categoría dentro de la que se agrupa; nulas en el nivel de categorías.
    category_id: int | None
    category_name: str | None
    groups: tuple[GroupPerformance, ...]


@dataclass(frozen=True)
class ProductPerformance:
    product_id: int
    name: str
    unit_of_measure: str
    category_id: int
    category_name: str
    subcategory_id: int | None
    subcategory_name: str | None
    units: Decimal
    revenue: Decimal
    profit: Decimal
    margin: Decimal


@dataclass(frozen=True)
class ProductRanking:
    order_by: str
    results: tuple[ProductPerformance, ...]


@dataclass(frozen=True)
class MatrixPoint:
    product_id: int
    name: str
    unit_of_measure: str
    units: Decimal
    revenue: Decimal
    profit: Decimal
    margin: Decimal
    quadrant: str


@dataclass(frozen=True)
class QuadrantCount:
    quadrant: str
    count: int


@dataclass(frozen=True)
class Matrix:
    median_units: Decimal
    median_margin: Decimal
    counts: tuple[QuadrantCount, ...]
    products: tuple[MatrixPoint, ...]


@dataclass(frozen=True)
class NoMovementItem:
    product_id: int
    name: str
    unit_of_measure: str
    stock: Decimal
    # Nula: el producto nunca se vendió en la sucursal.
    last_sale_date: date | None
    immobilized_capital: Decimal


@dataclass(frozen=True)
class RunningOutItem:
    product_id: int
    name: str
    unit_of_measure: str
    stock: Decimal
    daily_rate: Decimal
    days_left: Decimal


@dataclass(frozen=True)
class InventoryHealth:
    as_of: date
    no_sales_days: int
    max_days_left: int
    immobilized_capital_total: Decimal
    no_movement: tuple[NoMovementItem, ...]
    running_out: tuple[RunningOutItem, ...]


@dataclass(frozen=True)
class SplitTotals:
    revenue: Decimal
    profit: Decimal
    margin: Decimal


@dataclass(frozen=True)
class PendingTotals:
    """Lo que sigue sin cobrarse hoy de las ventas a crédito del período."""

    revenue: Decimal
    profit: Decimal


@dataclass(frozen=True)
class CreditBreakdown:
    """Ingresos y ganancia del período repartidos entre contado y crédito."""

    cash: SplitTotals
    credit: SplitTotals
    pending: PendingTotals
    # Porcentaje de los ingresos que se vendió a crédito.
    credit_share: Decimal
