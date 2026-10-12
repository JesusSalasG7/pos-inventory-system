"""Serializers de las estadísticas.

A diferencia del resto de la API, aquí los decimales viajan como números de
JSON y no como texto: son cifras para mostrar y graficar, no para operar.
"""

from typing import Any

from rest_framework import serializers

from apps.statistics.domain.enums import GroupLevel, Quadrant, RankingOrder
from apps.statistics.services import statistics_service
from core.enums import UnitOfMeasure


def _number(decimal_places: int, **kwargs: Any) -> serializers.DecimalField:
    return serializers.DecimalField(
        max_digits=18, decimal_places=decimal_places, coerce_to_string=False, **kwargs
    )


def _money(**kwargs: Any) -> serializers.DecimalField:
    return _number(2, **kwargs)


def _percent(**kwargs: Any) -> serializers.DecimalField:
    return _number(2, **kwargs)


def _quantity(**kwargs: Any) -> serializers.DecimalField:
    return _number(3, **kwargs)


class StatisticsFilterSerializer(serializers.Serializer):
    """Filtros globales de query string, comunes a todos los endpoints."""

    branch = serializers.CharField(
        max_length=20, required=False, help_text="Por defecto, la asignada al usuario."
    )
    date_from = serializers.DateField(
        required=False, help_text="Primer día, incluido. Por defecto, 30 días hasta `date_to`."
    )
    date_to = serializers.DateField(
        required=False, help_text="Último día, incluido. Por defecto, hoy."
    )
    category = serializers.IntegerField(min_value=1, required=False)
    subcategory = serializers.IntegerField(min_value=1, required=False)


class RankingQuerySerializer(StatisticsFilterSerializer):
    order_by = serializers.ChoiceField(choices=RankingOrder.choices, default=RankingOrder.PROFIT)
    limit = serializers.IntegerField(
        min_value=1,
        max_value=statistics_service.MAX_RANKING_LIMIT,
        default=statistics_service.DEFAULT_RANKING_LIMIT,
    )
    min_units = serializers.DecimalField(
        max_digits=12,
        decimal_places=3,
        min_value=0,
        default=statistics_service.DEFAULT_MIN_UNITS,
        help_text="Solo al ordenar por margen: unidades mínimas vendidas para entrar.",
    )


class InventoryHealthQuerySerializer(StatisticsFilterSerializer):
    no_sales_days = serializers.IntegerField(
        min_value=1,
        max_value=3650,
        default=statistics_service.DEFAULT_NO_SALES_DAYS,
        help_text="Días sin ventas para considerar un producto sin movimiento.",
    )
    max_days_left = serializers.IntegerField(
        min_value=0,
        max_value=3650,
        default=statistics_service.DEFAULT_MAX_DAYS_LEFT,
        help_text="Días de stock restantes para considerar un producto por agotarse.",
    )


class PeriodSerializer(serializers.Serializer):
    date_from = serializers.DateField()
    date_to = serializers.DateField()


class KpisSerializer(serializers.Serializer):
    revenue = _money()
    profit = _money()
    margin = _percent()
    units = _quantity()
    sales_count = serializers.IntegerField()
    average_ticket = _money()


class KpiChangesSerializer(serializers.Serializer):
    """Variación %; `margin` va en puntos porcentuales. Nulo: sin base de comparación."""

    revenue = _percent(allow_null=True)
    profit = _percent(allow_null=True)
    margin = _percent(allow_null=True)
    units = _percent(allow_null=True)
    sales_count = _percent(allow_null=True)
    average_ticket = _percent(allow_null=True)


class SummarySerializer(serializers.Serializer):
    period = PeriodSerializer()
    previous_period = PeriodSerializer()
    current = KpisSerializer()
    previous = KpisSerializer()
    change = KpiChangesSerializer()


class SplitTotalsSerializer(serializers.Serializer):
    revenue = _money()
    profit = _money()
    margin = _percent()


class PendingTotalsSerializer(serializers.Serializer):
    revenue = _money()
    profit = _money()


class CreditBreakdownSerializer(serializers.Serializer):
    cash = SplitTotalsSerializer()
    credit = SplitTotalsSerializer()
    pending = PendingTotalsSerializer(help_text="Lo que sigue sin cobrarse hoy.")
    credit_share = _percent(help_text="Porcentaje de los ingresos vendido a crédito.")


class GroupPerformanceSerializer(serializers.Serializer):
    id = serializers.IntegerField(allow_null=True)
    name = serializers.CharField()
    units = _quantity()
    revenue = _money()
    profit = _money()
    margin = _percent()


class GroupReportSerializer(serializers.Serializer):
    level = serializers.ChoiceField(choices=GroupLevel.choices)
    category_id = serializers.IntegerField(allow_null=True)
    category_name = serializers.CharField(allow_null=True)
    groups = GroupPerformanceSerializer(many=True)


class ProductPerformanceSerializer(serializers.Serializer):
    product_id = serializers.IntegerField()
    name = serializers.CharField()
    unit_of_measure = serializers.ChoiceField(choices=UnitOfMeasure.choices)
    category_id = serializers.IntegerField()
    category_name = serializers.CharField()
    subcategory_id = serializers.IntegerField(allow_null=True)
    subcategory_name = serializers.CharField(allow_null=True)
    units = _quantity()
    revenue = _money()
    profit = _money()
    margin = _percent()


class ProductRankingSerializer(serializers.Serializer):
    order_by = serializers.ChoiceField(choices=RankingOrder.choices)
    results = ProductPerformanceSerializer(many=True)


class MatrixPointSerializer(serializers.Serializer):
    product_id = serializers.IntegerField()
    name = serializers.CharField()
    unit_of_measure = serializers.ChoiceField(choices=UnitOfMeasure.choices)
    units = _quantity()
    revenue = _money()
    profit = _money()
    margin = _percent()
    quadrant = serializers.ChoiceField(choices=Quadrant.choices)


class QuadrantCountSerializer(serializers.Serializer):
    quadrant = serializers.ChoiceField(choices=Quadrant.choices)
    count = serializers.IntegerField()


class MatrixSerializer(serializers.Serializer):
    median_units = _quantity()
    median_margin = _percent()
    counts = QuadrantCountSerializer(many=True)
    products = MatrixPointSerializer(many=True)


class NoMovementItemSerializer(serializers.Serializer):
    product_id = serializers.IntegerField()
    name = serializers.CharField()
    unit_of_measure = serializers.ChoiceField(choices=UnitOfMeasure.choices)
    stock = _quantity()
    last_sale_date = serializers.DateField(allow_null=True, help_text="Nulo: nunca vendido.")
    immobilized_capital = _money()


class RunningOutItemSerializer(serializers.Serializer):
    product_id = serializers.IntegerField()
    name = serializers.CharField()
    unit_of_measure = serializers.ChoiceField(choices=UnitOfMeasure.choices)
    stock = _quantity()
    daily_rate = _quantity()
    days_left = _number(1)


class InventoryHealthSerializer(serializers.Serializer):
    as_of = serializers.DateField()
    no_sales_days = serializers.IntegerField()
    max_days_left = serializers.IntegerField()
    immobilized_capital_total = _money()
    no_movement = NoMovementItemSerializer(many=True)
    running_out = RunningOutItemSerializer(many=True)
