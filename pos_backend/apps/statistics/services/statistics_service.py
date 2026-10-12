"""Estadísticas de ventas e inventario de una sucursal.

Las fórmulas están en `metrics`; los datos salen de los services de `sales` e
`inventory`. Todo va en USD y las fechas, en la zona horaria de la tienda.
"""

from datetime import date, datetime, time, timedelta
from decimal import Decimal

from django.utils import timezone

from apps.inventory.services import category_service, stock_service, subcategory_service
from apps.sales.domain.dtos import ProductSalesAggregate, SalesAggregate
from apps.sales.services import sales_stats_service
from apps.statistics.domain.dtos import (
    CreditBreakdown,
    GroupPerformance,
    GroupReport,
    InventoryHealth,
    KpiChanges,
    Kpis,
    Matrix,
    MatrixPoint,
    NoMovementItem,
    PendingTotals,
    Period,
    ProductPerformance,
    ProductRanking,
    QuadrantCount,
    RunningOutItem,
    SplitTotals,
    StatisticsFilters,
    Summary,
)
from apps.statistics.domain.enums import GroupLevel, Quadrant, RankingOrder
from apps.statistics.services import metrics
from core.exceptions import DomainError
from core.money import quantize_money, quantize_quantity

NO_SUBCATEGORY_NAME = "Sin subcategoría"
DEFAULT_RANKING_LIMIT = 10
MAX_RANKING_LIMIT = 100
DEFAULT_MIN_UNITS = Decimal(5)
DEFAULT_NO_SALES_DAYS = 30
DEFAULT_MAX_DAYS_LEFT = 15
# Ventana fija con la que se mide el ritmo de venta para "por agotarse".
RATE_WINDOW_DAYS = 30


def get_summary(filters: StatisticsFilters) -> Summary:
    """KPIs del período y del anterior, con la variación de cada métrica."""
    period, category_id = _scope(filters)
    previous = metrics.previous_period(period)
    current_kpis = _kpis(_totals(filters, period, category_id))
    previous_kpis = _kpis(_totals(filters, previous, category_id))
    return Summary(
        period=period,
        previous_period=previous,
        current=current_kpis,
        previous=previous_kpis,
        change=_changes(current_kpis, previous_kpis),
    )


def get_credit_breakdown(filters: StatisticsFilters) -> CreditBreakdown:
    """Ingresos y ganancia del período repartidos entre contado y crédito.

    - Una venta a crédito cuenta entera el día en que se factura. Si solo una
      parte quedó como deuda, sus ingresos y su ganancia se reparten en esa
      proporción (deuda ÷ total de la venta).
    - Contado es el resto: las dos partes suman los totales del resumen.
    - `pending` es lo que sigue sin cobrarse **hoy** de esas ventas, con la
      ganancia que le corresponde; los abonos lo van reduciendo.
    """
    period, category_id = _scope(filters)
    start, end = _bounds(period)
    split = sales_stats_service.get_credit_split(
        branch=filters.branch,
        start=start,
        end=end,
        category_id=category_id,
        subcategory_id=filters.subcategory_id,
    )
    revenue = quantize_money(split.revenue_usd)
    profit = quantize_money(split.revenue_usd - split.cost_usd)
    credit_revenue = quantize_money(split.credit_revenue_usd)
    credit_profit = quantize_money(split.credit_revenue_usd - split.credit_cost_usd)
    return CreditBreakdown(
        cash=_split_totals(revenue - credit_revenue, profit - credit_profit),
        credit=_split_totals(credit_revenue, credit_profit),
        pending=PendingTotals(
            revenue=quantize_money(split.pending_revenue_usd),
            profit=quantize_money(split.pending_revenue_usd - split.pending_cost_usd),
        ),
        credit_share=metrics.margin_percent(credit_revenue, revenue),
    )


def _split_totals(revenue: Decimal, profit: Decimal) -> SplitTotals:
    return SplitTotals(
        revenue=revenue, profit=profit, margin=metrics.margin_percent(profit, revenue)
    )


def get_group_performance(filters: StatisticsFilters) -> GroupReport:
    """Rendimiento por categoría o, dentro de una categoría, por subcategoría.

    Ordenado por ganancia, de mayor a menor. Solo aparecen grupos con ventas.
    """
    period, category_id = _scope(filters)
    start, end = _bounds(period)
    if category_id is None:
        level, category_name = GroupLevel.CATEGORY, None
        rows = sales_stats_service.get_totals_by_category(
            branch=filters.branch, start=start, end=end
        )
    else:
        level = GroupLevel.SUBCATEGORY
        category_name = category_service.get_category(category_id).name
        rows = sales_stats_service.get_totals_by_subcategory(
            branch=filters.branch,
            start=start,
            end=end,
            category_id=category_id,
            subcategory_id=filters.subcategory_id,
        )
    groups = [
        GroupPerformance(
            id=row.id,
            name=row.name or NO_SUBCATEGORY_NAME,
            units=row.totals.units,
            revenue=row.totals.revenue_usd,
            profit=row.totals.profit_usd,
            margin=metrics.margin_percent(row.totals.profit_usd, row.totals.revenue_usd),
        )
        for row in rows
    ]
    groups.sort(key=lambda group: (-group.profit, group.name))
    return GroupReport(
        level=level, category_id=category_id, category_name=category_name, groups=tuple(groups)
    )


def get_product_ranking(
    filters: StatisticsFilters,
    *,
    order_by: RankingOrder = RankingOrder.PROFIT,
    limit: int = DEFAULT_RANKING_LIMIT,
    min_units: Decimal = DEFAULT_MIN_UNITS,
) -> ProductRanking:
    """Los `limit` productos con más unidades, ingresos, ganancia o margen.

    Al ordenar por margen se dejan fuera los productos con menos de
    `min_units` unidades vendidas: un margen alto con una sola venta no dice nada.
    """
    products = _product_performance(filters)
    if order_by == RankingOrder.MARGIN:
        products = [product for product in products if product.units >= min_units]
    products.sort(key=lambda product: (-getattr(product, order_by), product.name))
    return ProductRanking(order_by=order_by, results=tuple(products[:limit]))


def get_matrix(filters: StatisticsFilters) -> Matrix:
    """Matriz volumen vs. margen de los productos con ventas en el período.

    Los cortes son las medianas de unidades y de margen, no los promedios.
    """
    products = _product_performance(filters)
    median_units = metrics.median([product.units for product in products])
    median_margin = metrics.median([product.margin for product in products])
    points = tuple(
        MatrixPoint(
            product_id=product.product_id,
            name=product.name,
            unit_of_measure=product.unit_of_measure,
            units=product.units,
            revenue=product.revenue,
            profit=product.profit,
            margin=product.margin,
            quadrant=metrics.quadrant(
                product.units,
                product.margin,
                median_units=median_units,
                median_margin=median_margin,
            ),
        )
        for product in sorted(products, key=lambda product: product.name)
    )
    counts = tuple(
        QuadrantCount(
            quadrant=quadrant, count=sum(1 for point in points if point.quadrant == quadrant)
        )
        for quadrant in Quadrant
    )
    return Matrix(
        median_units=quantize_quantity(median_units),
        median_margin=metrics.quantize_percent(median_margin),
        counts=counts,
        products=points,
    )


def get_inventory_health(
    filters: StatisticsFilters,
    *,
    no_sales_days: int = DEFAULT_NO_SALES_DAYS,
    max_days_left: int = DEFAULT_MAX_DAYS_LEFT,
) -> InventoryHealth:
    """Productos sin movimiento y productos por agotarse, a la fecha de hoy.

    No usa el período de los filtros, solo la categoría y la subcategoría.

    - Sin movimiento: con stock y sin ventas en los últimos `no_sales_days`
      días (o nunca vendidos). Capital inmovilizado = stock × costo actual.
      Ordenados por capital, de mayor a menor.
    - Por agotarse: productos activos con ventas en los últimos 30 días cuyo
      stock, al ritmo de esos 30 días, dura `max_days_left` días o menos.
      Ordenados por días restantes, de menor a mayor.
    """
    _, category_id = _scope(filters)
    now = timezone.now()
    stale_before = now - timedelta(days=no_sales_days)
    activity = sales_stats_service.get_activity_by_product(
        branch=filters.branch, since=now - timedelta(days=RATE_WINDOW_DAYS)
    )

    no_movement: list[NoMovementItem] = []
    running_out: list[RunningOutItem] = []
    for item in stock_service.get_product_stock(
        filters.branch, category_id=category_id, subcategory_id=filters.subcategory_id
    ):
        sold = activity.get(item.product_id)
        if item.current_stock > 0 and (sold is None or sold.last_sale_at < stale_before):
            no_movement.append(
                NoMovementItem(
                    product_id=item.product_id,
                    name=item.product_name,
                    unit_of_measure=item.unit_of_measure,
                    stock=item.current_stock,
                    last_sale_date=timezone.localdate(sold.last_sale_at) if sold else None,
                    immobilized_capital=quantize_money(item.current_stock * item.cost_price_usd),
                )
            )
        if item.active and sold is not None and sold.recent_units > 0:
            daily_rate = sold.recent_units / RATE_WINDOW_DAYS
            remaining = metrics.days_left(item.current_stock, daily_rate)
            if remaining <= max_days_left:
                running_out.append(
                    RunningOutItem(
                        product_id=item.product_id,
                        name=item.product_name,
                        unit_of_measure=item.unit_of_measure,
                        stock=item.current_stock,
                        daily_rate=quantize_quantity(daily_rate),
                        days_left=remaining,
                    )
                )

    no_movement.sort(key=lambda item: (-item.immobilized_capital, item.name))
    running_out.sort(key=lambda item: (item.days_left, item.name))
    return InventoryHealth(
        as_of=timezone.localdate(now),
        no_sales_days=no_sales_days,
        max_days_left=max_days_left,
        immobilized_capital_total=sum(
            (item.immobilized_capital for item in no_movement), metrics.ZERO
        ),
        no_movement=tuple(no_movement),
        running_out=tuple(running_out),
    )


def _scope(filters: StatisticsFilters) -> tuple[Period, int | None]:
    """Valida los filtros y devuelve el período y la categoría efectiva.

    Una subcategoría fija también su categoría. Lanza `invalid_period` (422),
    `category_not_found` / `subcategory_not_found` (404) o
    `subcategory_category_mismatch` (422).
    """
    period = metrics.resolve_period(filters.date_from, filters.date_to, today=timezone.localdate())
    if period.date_from > period.date_to:
        raise DomainError(
            "La fecha inicial no puede ser posterior a la final.",
            code="invalid_period",
            status_code=422,
            meta={"date_from": str(period.date_from), "date_to": str(period.date_to)},
        )

    category_id = filters.category_id
    if category_id is not None:
        category_service.get_category(category_id)
    if filters.subcategory_id is not None:
        subcategory = subcategory_service.get_subcategory(filters.subcategory_id)
        if category_id is not None and subcategory.category_id != category_id:
            raise DomainError(
                "La subcategoría no pertenece a la categoría indicada.",
                code="subcategory_category_mismatch",
                status_code=422,
                meta={"subcategory_id": subcategory.pk, "category_id": category_id},
            )
        category_id = subcategory.category_id
    return period, category_id


def _bounds(period: Period) -> tuple[datetime, datetime]:
    """Instantes `[inicio, fin)` del período en la zona horaria de la tienda."""
    return _start_of_day(period.date_from), _start_of_day(period.date_to + timedelta(days=1))


def _start_of_day(day: date) -> datetime:
    return timezone.make_aware(datetime.combine(day, time.min))


def _totals(filters: StatisticsFilters, period: Period, category_id: int | None) -> SalesAggregate:
    start, end = _bounds(period)
    return sales_stats_service.get_totals(
        branch=filters.branch,
        start=start,
        end=end,
        category_id=category_id,
        subcategory_id=filters.subcategory_id,
    )


def _kpis(totals: SalesAggregate) -> Kpis:
    return Kpis(
        revenue=totals.revenue_usd,
        profit=totals.profit_usd,
        margin=metrics.margin_percent(totals.profit_usd, totals.revenue_usd),
        units=totals.units,
        sales_count=totals.sales_count,
        average_ticket=metrics.average_ticket(totals.revenue_usd, totals.sales_count),
    )


def _changes(current: Kpis, previous: Kpis) -> KpiChanges:
    return KpiChanges(
        revenue=metrics.change_percent(current.revenue, previous.revenue),
        profit=metrics.change_percent(current.profit, previous.profit),
        # Sin ventas en el período anterior no hay margen con el que comparar.
        margin=current.margin - previous.margin if previous.sales_count else None,
        units=metrics.change_percent(current.units, previous.units),
        sales_count=metrics.change_percent(current.sales_count, previous.sales_count),
        average_ticket=metrics.change_percent(current.average_ticket, previous.average_ticket),
    )


def _product_performance(filters: StatisticsFilters) -> list[ProductPerformance]:
    period, category_id = _scope(filters)
    start, end = _bounds(period)
    rows = sales_stats_service.get_totals_by_product(
        branch=filters.branch,
        start=start,
        end=end,
        category_id=category_id,
        subcategory_id=filters.subcategory_id,
    )
    return [_performance(row) for row in rows]


def _performance(row: ProductSalesAggregate) -> ProductPerformance:
    return ProductPerformance(
        product_id=row.product_id,
        name=row.product_name,
        unit_of_measure=row.unit_of_measure,
        category_id=row.category_id,
        category_name=row.category_name,
        subcategory_id=row.subcategory_id,
        subcategory_name=row.subcategory_name,
        units=row.totals.units,
        revenue=row.totals.revenue_usd,
        profit=row.totals.profit_usd,
        margin=metrics.margin_percent(row.totals.profit_usd, row.totals.revenue_usd),
    )
