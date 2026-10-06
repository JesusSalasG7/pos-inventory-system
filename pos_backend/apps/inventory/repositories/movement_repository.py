"""Acceso a datos del Kardex. Solo inserta y consulta: nunca actualiza ni borra."""

from collections.abc import Sequence
from decimal import Decimal

from django.db.models import QuerySet

from apps.auth.models import User
from apps.inventory.models import InventoryMovement
from apps.sales.models import Sale
from core.enums import MovementType


def create(
    *,
    product_id: int,
    branch: str,
    movement_type: MovementType,
    quantity: Decimal,
    stock_before: Decimal,
    stock_after: Decimal,
    user: User,
    sale: Sale | None = None,
    notes: str = "",
) -> InventoryMovement:
    """Inserta un movimiento de Kardex."""
    return InventoryMovement.objects.create(
        product_id=product_id,
        branch_id=branch,
        movement_type=movement_type,
        quantity=quantity,
        stock_before=stock_before,
        stock_after=stock_after,
        user=user,
        sale=sale,
        notes=notes,
    )


def bulk_create(movements: Sequence[InventoryMovement]) -> list[InventoryMovement]:
    """Inserta varios movimientos con un único `bulk_create` (ventas multilínea)."""
    return InventoryMovement.objects.bulk_create(movements)


def list_movements(branch: str) -> QuerySet[InventoryMovement]:
    """Devuelve el Kardex de la sucursal, del más reciente al más antiguo.

    Los filtros adicionales (producto, tipo, fechas) los aplica
    `InventoryMovementFilter` sobre este queryset.
    """
    return InventoryMovement.objects.filter(branch_id=branch).order_by("-created_at", "-id")
