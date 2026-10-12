"""Agregados de ventas para las estadísticas. Solo lectura."""

from datetime import datetime
from typing import Any

from django.db.models import Case, Count, DecimalField, F, Max, Q, QuerySet, Sum, Value, When
from django.db.models.functions import Coalesce, Least, Round

from apps.sales.models import SaleDetail

MONEY = DecimalField(max_digits=14, decimal_places=2)
QUANTITY = DecimalField(max_digits=12, decimal_places=3)
# Importes intermedios del reparto contado/crédito: se redondean al final.
SHARE = DecimalField(max_digits=24, decimal_places=10)

# Costo de la línea: cantidad × costo congelado, redondeado a 2 decimales por
# línea, igual que en el resumen de caja (`sales_report_service`).
LINE_COST = Round(F("quantity") * F("unit_cost_usd"), precision=2, output_field=MONEY)

TOTALS = {
    "units": Coalesce(Sum("quantity"), 0, output_field=QUANTITY),
    "revenue_usd": Coalesce(Sum("subtotal_usd"), 0, output_field=MONEY),
    "cost_usd": Coalesce(Sum(LINE_COST), 0, output_field=MONEY),
    "sales_count": Count("sale_id", distinct=True),
}


def totals(
    *,
    branch: str,
    start: datetime,
    end: datetime,
    category_id: int | None = None,
    subcategory_id: int | None = None,
) -> dict[str, Any]:
    """Unidades, ingresos, costo y número de ventas del período."""
    return _lines(
        branch=branch,
        start=start,
        end=end,
        category_id=category_id,
        subcategory_id=subcategory_id,
    ).aggregate(**TOTALS)


def totals_by_category(*, branch: str, start: datetime, end: datetime) -> list[dict[str, Any]]:
    """Totales del período agrupados por la categoría actual del producto."""
    return list(
        _lines(branch=branch, start=start, end=end)
        .values(group_id=F("product__category_id"), group_name=F("product__category__name"))
        .annotate(**TOTALS)
    )


def totals_by_subcategory(
    *,
    branch: str,
    start: datetime,
    end: datetime,
    category_id: int,
    subcategory_id: int | None = None,
) -> list[dict[str, Any]]:
    """Totales de una categoría agrupados por subcategoría.

    Los productos sin subcategoría forman un grupo con `group_id` nulo.
    """
    return list(
        _lines(
            branch=branch,
            start=start,
            end=end,
            category_id=category_id,
            subcategory_id=subcategory_id,
        )
        .values(group_id=F("product__subcategory_id"), group_name=F("product__subcategory__name"))
        .annotate(**TOTALS)
    )


def totals_by_product(
    *,
    branch: str,
    start: datetime,
    end: datetime,
    category_id: int | None = None,
    subcategory_id: int | None = None,
) -> list[dict[str, Any]]:
    """Totales del período por producto, con su categoría y subcategoría."""
    return list(
        _lines(
            branch=branch,
            start=start,
            end=end,
            category_id=category_id,
            subcategory_id=subcategory_id,
        )
        .values(
            "product_id",
            product_name=F("product__name"),
            unit_of_measure=F("product__unit_of_measure"),
            category_id=F("product__category_id"),
            category_name=F("product__category__name"),
            subcategory_id=F("product__subcategory_id"),
            subcategory_name=F("product__subcategory__name"),
        )
        .annotate(**TOTALS)
    )


def credit_split(
    *,
    branch: str,
    start: datetime,
    end: datetime,
    category_id: int | None = None,
    subcategory_id: int | None = None,
) -> dict[str, Any]:
    """Ingresos y costo del período, con la parte a crédito y la parte aún sin cobrar.

    Cada línea se reparte en la proporción de su venta que quedó como deuda
    (`Credit.amount_usd ÷ Sale.total_usd`) y en la que sigue pendiente
    (`Credit.balance_usd ÷ Sale.total_usd`). Los importes no se redondean aquí.
    """
    return _lines(
        branch=branch,
        start=start,
        end=end,
        category_id=category_id,
        subcategory_id=subcategory_id,
    ).aggregate(
        revenue_usd=_sum(F("subtotal_usd")),
        cost_usd=_sum(LINE_COST),
        credit_revenue_usd=_sum(F("subtotal_usd") * _sale_share("amount_usd")),
        credit_cost_usd=_sum(LINE_COST * _sale_share("amount_usd")),
        pending_revenue_usd=_sum(F("subtotal_usd") * _sale_share("balance_usd")),
        pending_cost_usd=_sum(LINE_COST * _sale_share("balance_usd")),
    )


def _sum(expression: Any) -> Coalesce:
    return Coalesce(Sum(expression, output_field=SHARE), 0, output_field=SHARE)


def _sale_share(credit_field: str) -> Case:
    """Fracción (0 a 1) de la venta de la línea que representa ese campo de su deuda."""
    return Case(
        When(
            sale__credit__isnull=False,
            sale__total_usd__gt=0,
            then=Least(
                F(f"sale__credit__{credit_field}") / F("sale__total_usd"),
                Value(1, output_field=SHARE),
                output_field=SHARE,
            ),
        ),
        default=Value(0, output_field=SHARE),
        output_field=SHARE,
    )


def activity_by_product(*, branch: str, since: datetime) -> list[dict[str, Any]]:
    """Por producto vendido alguna vez: última venta y unidades vendidas desde `since`."""
    return list(
        _lines(branch=branch)
        .values("product_id")
        .annotate(
            last_sale_at=Max("sale__created_at"),
            recent_units=Coalesce(
                Sum("quantity", filter=Q(sale__created_at__gte=since)), 0, output_field=QUANTITY
            ),
        )
    )


def _lines(
    *,
    branch: str,
    start: datetime | None = None,
    end: datetime | None = None,
    category_id: int | None = None,
    subcategory_id: int | None = None,
) -> QuerySet[SaleDetail]:
    """Líneas de las ventas que cuentan para las estadísticas.

    Es el único punto por el que pasan todas las consultas: si algún día las
    ventas se pueden anular o devolver, se excluyen aquí.
    El período es `[start, end)`.
    """
    queryset = SaleDetail.objects.filter(sale__branch_id=branch)
    if start is not None:
        queryset = queryset.filter(sale__created_at__gte=start)
    if end is not None:
        queryset = queryset.filter(sale__created_at__lt=end)
    if category_id is not None:
        queryset = queryset.filter(product__category_id=category_id)
    if subcategory_id is not None:
        queryset = queryset.filter(product__subcategory_id=subcategory_id)
    return queryset
