"""Filtros del Kardex."""

import django_filters

from apps.inventory.models import InventoryMovement
from core.enums import MovementType


class InventoryMovementFilter(django_filters.FilterSet):
    branch = django_filters.CharFilter(field_name="branch_id")
    product = django_filters.NumberFilter(field_name="product_id")
    movement_type = django_filters.ChoiceFilter(choices=MovementType.choices)
    created_from = django_filters.IsoDateTimeFilter(field_name="created_at", lookup_expr="gte")
    created_to = django_filters.IsoDateTimeFilter(field_name="created_at", lookup_expr="lte")

    class Meta:
        model = InventoryMovement
        fields = ["branch", "product", "movement_type", "created_from", "created_to"]
