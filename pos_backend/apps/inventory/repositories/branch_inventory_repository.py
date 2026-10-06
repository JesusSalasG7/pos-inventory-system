"""Acceso a datos de las existencias por sucursal."""

from collections.abc import Iterable
from decimal import Decimal

from django.db.models import F, QuerySet
from django.utils import timezone

from apps.inventory.models import BranchInventory, Product


def list_by_branch(branch: str) -> QuerySet[BranchInventory]:
    """Lista el inventario de la sucursal con el producto precargado."""
    return (
        BranchInventory.objects.filter(branch_id=branch)
        .select_related("product")
        .order_by("product__name", "id")
    )


def list_low_stock(branch: str) -> QuerySet[BranchInventory]:
    """Lista los productos activos con `current_stock <= minimum_stock`."""
    return list_by_branch(branch).filter(
        product__active=True, current_stock__lte=F("minimum_stock")
    )


def get(branch: str, product_id: int) -> BranchInventory | None:
    """Devuelve la fila de inventario del producto en la sucursal, o None."""
    return BranchInventory.objects.filter(branch_id=branch, product_id=product_id).first()


def get_or_create(branch: str, product_id: int) -> BranchInventory:
    """Devuelve la fila de inventario, creándola con stock cero si no existe."""
    inventory, _ = BranchInventory.objects.get_or_create(branch_id=branch, product_id=product_id)
    return inventory


def create_for_branches(product: Product, branches: Iterable[str]) -> list[BranchInventory]:
    """Crea en stock cero las filas de inventario de un producto nuevo."""
    return BranchInventory.objects.bulk_create(
        [BranchInventory(product=product, branch_id=branch) for branch in branches]
    )


def create_missing_for_branch(branch: str) -> None:
    """Crea en stock cero las filas de la sucursal para los productos que no la tengan."""
    BranchInventory.objects.bulk_create(
        [
            BranchInventory(product_id=product_id, branch_id=branch)
            for product_id in Product.objects.values_list("pk", flat=True)
        ],
        ignore_conflicts=True,
    )


def lock_for_update(branch: str, product_ids: Iterable[int]) -> list[BranchInventory]:
    """Bloquea las filas de inventario de los productos indicados.

    Usa `select_for_update()` ordenando por `product_id`: todas las
    transacciones toman los bloqueos en el mismo orden y así no pueden
    interbloquearse. Debe llamarse dentro de `transaction.atomic()`.
    """
    return list(
        BranchInventory.objects.select_for_update()
        .filter(branch_id=branch, product_id__in=list(product_ids))
        .order_by("product_id")
    )


def decrease_stock(inventory_id: int, quantity: Decimal) -> None:
    """Descuenta stock en la base de datos con `F("current_stock") - quantity`."""
    BranchInventory.objects.filter(pk=inventory_id).update(
        current_stock=F("current_stock") - quantity, updated_at=timezone.now()
    )


def increase_stock(inventory_id: int, quantity: Decimal) -> None:
    """Suma stock en la base de datos con `F("current_stock") + quantity`."""
    BranchInventory.objects.filter(pk=inventory_id).update(
        current_stock=F("current_stock") + quantity, updated_at=timezone.now()
    )


def set_minimum_stock(inventory: BranchInventory, minimum_stock: Decimal) -> BranchInventory:
    """Actualiza el stock mínimo que dispara la alerta de reposición."""
    inventory.minimum_stock = minimum_stock
    inventory.save(update_fields=["minimum_stock", "updated_at"])
    return inventory
