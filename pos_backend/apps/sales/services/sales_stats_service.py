"""Agregados de ventas que consume la app de estadísticas.

Todos los períodos son `[start, end)` y todas las consultas van acotadas a una
sucursal ya resuelta por quien llama.
"""

from datetime import datetime
from typing import Any

from apps.sales.domain.dtos import (
    CreditSplitAggregate,
    GroupSalesAggregate,
    ProductSalesActivity,
    ProductSalesAggregate,
    SalesAggregate,
)
from apps.sales.repositories import sales_stats_repository


def get_totals(
    *,
    branch: str,
    start: datetime,
    end: datetime,
    category_id: int | None = None,
    subcategory_id: int | None = None,
) -> SalesAggregate:
    """Totales del período, opcionalmente de una categoría o subcategoría."""
    return _aggregate(
        sales_stats_repository.totals(
            branch=branch,
            start=start,
            end=end,
            category_id=category_id,
            subcategory_id=subcategory_id,
        )
    )


def get_totals_by_category(
    *, branch: str, start: datetime, end: datetime
) -> list[GroupSalesAggregate]:
    """Totales del período de cada categoría con ventas."""
    rows = sales_stats_repository.totals_by_category(branch=branch, start=start, end=end)
    return [_group(row) for row in rows]


def get_totals_by_subcategory(
    *,
    branch: str,
    start: datetime,
    end: datetime,
    category_id: int,
    subcategory_id: int | None = None,
) -> list[GroupSalesAggregate]:
    """Totales del período de cada subcategoría con ventas dentro de una categoría."""
    rows = sales_stats_repository.totals_by_subcategory(
        branch=branch,
        start=start,
        end=end,
        category_id=category_id,
        subcategory_id=subcategory_id,
    )
    return [_group(row) for row in rows]


def get_totals_by_product(
    *,
    branch: str,
    start: datetime,
    end: datetime,
    category_id: int | None = None,
    subcategory_id: int | None = None,
) -> list[ProductSalesAggregate]:
    """Totales del período de cada producto con ventas."""
    rows = sales_stats_repository.totals_by_product(
        branch=branch,
        start=start,
        end=end,
        category_id=category_id,
        subcategory_id=subcategory_id,
    )
    return [
        ProductSalesAggregate(
            product_id=row["product_id"],
            product_name=row["product_name"],
            unit_of_measure=row["unit_of_measure"],
            category_id=row["category_id"],
            category_name=row["category_name"],
            subcategory_id=row["subcategory_id"],
            subcategory_name=row["subcategory_name"],
            totals=_aggregate(row),
        )
        for row in rows
    ]


def get_credit_split(
    *,
    branch: str,
    start: datetime,
    end: datetime,
    category_id: int | None = None,
    subcategory_id: int | None = None,
) -> CreditSplitAggregate:
    """Lo vendido en el período, con la parte a crédito y la parte aún sin cobrar."""
    return CreditSplitAggregate(
        **sales_stats_repository.credit_split(
            branch=branch,
            start=start,
            end=end,
            category_id=category_id,
            subcategory_id=subcategory_id,
        )
    )


def get_activity_by_product(*, branch: str, since: datetime) -> dict[int, ProductSalesActivity]:
    """Última venta y unidades vendidas desde `since`, por producto vendido alguna vez."""
    return {
        row["product_id"]: ProductSalesActivity(
            last_sale_at=row["last_sale_at"], recent_units=row["recent_units"]
        )
        for row in sales_stats_repository.activity_by_product(branch=branch, since=since)
    }


def _aggregate(row: dict[str, Any]) -> SalesAggregate:
    return SalesAggregate(
        units=row["units"],
        revenue_usd=row["revenue_usd"],
        cost_usd=row["cost_usd"],
        sales_count=row["sales_count"],
    )


def _group(row: dict[str, Any]) -> GroupSalesAggregate:
    return GroupSalesAggregate(id=row["group_id"], name=row["group_name"], totals=_aggregate(row))
