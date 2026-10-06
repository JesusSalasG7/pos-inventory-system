"""Único punto del sistema que altera el stock y registra el Kardex.

Ningún otro módulo debe modificar `BranchInventory.current_stock` ni crear
filas de `InventoryMovement`. Toda operación de este service actualiza el
stock y escribe su movimiento dentro de la misma transacción.
"""

from collections.abc import Mapping
from decimal import Decimal

from django.db import transaction
from django.db.models import QuerySet

from apps.auth.models import User
from apps.inventory.models import BranchInventory, InventoryMovement
from apps.inventory.repositories import branch_inventory_repository, movement_repository
from apps.inventory.services import product_service
from apps.sales.models import Sale
from core.branch_scope import can_access_branch
from core.enums import MovementType
from core.exceptions import (
    BranchAccessDeniedError,
    DomainError,
    InactiveProductError,
    InsufficientStockError,
)
from core.money import quantize_quantity


def get_branch_inventory(branch: str) -> QuerySet[BranchInventory]:
    """Lista las existencias de la sucursal."""
    return branch_inventory_repository.list_by_branch(branch)


def get_low_stock(branch: str) -> QuerySet[BranchInventory]:
    """Lista los productos activos cuyo stock está en o por debajo del mínimo."""
    return branch_inventory_repository.list_low_stock(branch)


def set_minimum_stock(branch: str, product_id: int, minimum_stock: Decimal) -> BranchInventory:
    """Define el stock mínimo de un producto en la sucursal (no genera Kardex)."""
    minimum_stock = quantize_quantity(minimum_stock)
    if minimum_stock < 0:
        raise _invalid_quantity("El stock mínimo no puede ser negativo.", minimum_stock)
    product_service.get_product(product_id)
    inventory = branch_inventory_repository.get_or_create(branch, product_id)
    return branch_inventory_repository.set_minimum_stock(inventory, minimum_stock)


def initialize_branch(branch: str) -> None:
    """Crea en stock cero las filas de inventario que le falten a la sucursal.

    Lo llama `branch_service` al crear o reactivar una sucursal. No genera
    Kardex: no hay movimiento de mercancía.
    """
    branch_inventory_repository.create_missing_for_branch(branch)


def list_movements(branch: str) -> QuerySet[InventoryMovement]:
    """Devuelve el Kardex de la sucursal para ser filtrado y paginado en la vista."""
    return movement_repository.list_movements(branch)


def register_manual_movement(
    *,
    movement_type: str,
    branch: str,
    product_id: int,
    quantity: Decimal,
    user: User,
    notes: str = "",
) -> InventoryMovement | None:
    """Despacha un movimiento manual (ENTRY, WASTE o ADJUSTMENT).

    En un ADJUSTMENT, `quantity` es el stock contado, no la diferencia. Los
    movimientos SALE solo los genera `discount_for_sale`.
    """
    common = {"branch": branch, "product_id": product_id, "user": user, "notes": notes}
    if movement_type == MovementType.ENTRY:
        return register_entry(quantity=quantity, **common)
    if movement_type == MovementType.WASTE:
        return register_waste(quantity=quantity, **common)
    if movement_type == MovementType.ADJUSTMENT:
        return register_adjustment(counted_stock=quantity, **common)
    raise DomainError(
        "Tipo de movimiento manual no permitido.",
        code="invalid_movement_type",
        status_code=422,
        meta={"movement_type": movement_type},
    )


def register_entry(
    *, branch: str, product_id: int, quantity: Decimal, user: User, notes: str = ""
) -> InventoryMovement:
    """Registra una entrada de mercancía.

    Solo se admite para productos activos. Pasos, dentro de `transaction.atomic()`:
    1. Validar que `quantity` sea mayor que cero.
    2. Bloquear la fila de inventario; crearla si no existe.
    3. Sumar el stock con `F()`.
    4. Registrar el movimiento ENTRY con `stock_before` y `stock_after`.
    """
    _require_branch_access(user, branch)
    quantity = _positive_quantity(quantity)
    if not product_service.get_product(product_id).active:
        raise InactiveProductError(meta={"product_ids": [product_id]})

    with transaction.atomic():
        inventory = _lock_one(branch, product_id, create=True)
        return _apply(inventory, quantity, MovementType.ENTRY, user, notes)


def register_waste(
    *, branch: str, product_id: int, quantity: Decimal, user: User, notes: str = ""
) -> InventoryMovement:
    """Registra una merma (producto dañado, vencido o perdido).

    Pasos, dentro de `transaction.atomic()`:
    1. Validar que `quantity` sea mayor que cero.
    2. Bloquear la fila de inventario.
    3. Validar que haya stock suficiente (InsufficientStockError → 422).
    4. Descontar el stock con `F()` y registrar el movimiento WASTE.
    """
    _require_branch_access(user, branch)
    quantity = _positive_quantity(quantity)
    product_service.get_product(product_id)

    with transaction.atomic():
        inventory = _lock_one(branch, product_id, create=False)
        available = inventory.current_stock if inventory else Decimal("0")
        if inventory is None or available < quantity:
            raise InsufficientStockError(
                meta={"items": [_shortage(product_id, quantity, available)]}
            )
        return _apply(inventory, -quantity, MovementType.WASTE, user, notes)


def register_adjustment(
    *, branch: str, product_id: int, counted_stock: Decimal, user: User, notes: str = ""
) -> InventoryMovement | None:
    """Ajusta el stock al valor contado en un inventario físico.

    Pasos, dentro de `transaction.atomic()`:
    1. Validar que `counted_stock` no sea negativo.
    2. Bloquear la fila de inventario; crearla si no existe.
    3. Calcular la diferencia contra el stock actual; si es cero no hace nada
       y devuelve None.
    4. Aplicar la diferencia y registrar el movimiento ADJUSTMENT.
    """
    _require_branch_access(user, branch)
    counted_stock = quantize_quantity(counted_stock)
    if counted_stock < 0:
        raise _invalid_quantity("El stock contado no puede ser negativo.", counted_stock)
    product_service.get_product(product_id)

    with transaction.atomic():
        inventory = _lock_one(branch, product_id, create=True)
        difference = counted_stock - inventory.current_stock
        if difference == 0:
            return None
        return _apply(inventory, difference, MovementType.ADJUSTMENT, user, notes)


def lock_and_validate_stock(
    branch: str, quantities: Mapping[int, Decimal]
) -> dict[int, BranchInventory]:
    """Bloquea el inventario de una venta y valida que alcance.

    `quantities` asocia cada `product_id` con la cantidad total a vender.
    Debe llamarse dentro de la transacción de `sale_service.create_sale`.

    Pasos:
    1. `branch_inventory_repository.lock_for_update(branch, product_ids)`,
       que bloquea ordenando por `product_id`.
    2. Comparar el stock bloqueado con lo solicitado. Si algún producto no
       tiene fila o no alcanza, lanzar InsufficientStockError con el detalle
       por producto (solicitado y disponible) en `meta`.
    3. Devolver las filas bloqueadas indexadas por `product_id`.
    """
    locked = {
        inventory.product_id: inventory
        for inventory in branch_inventory_repository.lock_for_update(branch, quantities.keys())
    }
    shortages = []
    for product_id in sorted(quantities):
        requested = quantities[product_id]
        if requested <= 0:
            raise _invalid_quantity("La cantidad debe ser mayor que cero.", requested)
        available = locked[product_id].current_stock if product_id in locked else Decimal("0")
        if available < requested:
            shortages.append(_shortage(product_id, requested, available))
    if shortages:
        raise InsufficientStockError(meta={"items": shortages})
    return locked


def discount_for_sale(
    *,
    sale: Sale,
    locked_inventory: Mapping[int, BranchInventory],
    quantities: Mapping[int, Decimal],
    user: User,
) -> list[InventoryMovement]:
    """Descuenta el stock de una venta y registra su Kardex.

    Requiere las filas ya bloqueadas por `lock_and_validate_stock` en la misma
    transacción.

    Pasos:
    1. Descontar cada producto con `F("current_stock") - quantity`.
    2. Registrar con `bulk_create` un movimiento SALE por producto, enlazado a
       la venta, con `stock_before` y `stock_after` calculados a partir de la
       fila bloqueada.
    """
    movements = []
    for product_id in sorted(quantities):
        inventory = locked_inventory[product_id]
        quantity = quantities[product_id]
        stock_before = inventory.current_stock
        branch_inventory_repository.decrease_stock(inventory.pk, quantity)
        inventory.current_stock = stock_before - quantity
        movements.append(
            InventoryMovement(
                product_id=product_id,
                branch_id=sale.branch_id,
                movement_type=MovementType.SALE,
                quantity=quantity,
                stock_before=stock_before,
                stock_after=inventory.current_stock,
                user=user,
                sale=sale,
            )
        )
    return movement_repository.bulk_create(movements)


def _lock_one(branch: str, product_id: int, *, create: bool) -> BranchInventory | None:
    """Bloquea la fila de un producto; con `create` la crea antes si falta."""
    if create:
        branch_inventory_repository.get_or_create(branch, product_id)
    locked = branch_inventory_repository.lock_for_update(branch, [product_id])
    return locked[0] if locked else None


def _apply(
    inventory: BranchInventory, delta: Decimal, movement_type: MovementType, user: User, notes: str
) -> InventoryMovement:
    """Aplica `delta` (con signo) a una fila bloqueada y escribe su Kardex."""
    stock_before = inventory.current_stock
    if delta > 0:
        branch_inventory_repository.increase_stock(inventory.pk, delta)
    else:
        branch_inventory_repository.decrease_stock(inventory.pk, -delta)
    inventory.current_stock = stock_before + delta
    return movement_repository.create(
        product_id=inventory.product_id,
        branch=inventory.branch_id,
        movement_type=movement_type,
        quantity=abs(delta),
        stock_before=stock_before,
        stock_after=inventory.current_stock,
        user=user,
        notes=notes.strip(),
    )


def _positive_quantity(quantity: Decimal) -> Decimal:
    quantity = quantize_quantity(quantity)
    if quantity <= 0:
        raise _invalid_quantity("La cantidad debe ser mayor que cero.", quantity)
    return quantity


def _invalid_quantity(detail: str, quantity: Decimal) -> DomainError:
    return DomainError(
        detail, code="invalid_quantity", status_code=422, meta={"quantity": str(quantity)}
    )


def _shortage(product_id: int, requested: Decimal, available: Decimal) -> dict[str, object]:
    return {"product_id": product_id, "requested": str(requested), "available": str(available)}


def _require_branch_access(user: User, branch: str) -> None:
    if not can_access_branch(user, branch):
        raise BranchAccessDeniedError(
            meta={"requested_branch": branch, "assigned_branch": user.assigned_branch_id}
        )
