import threading
from decimal import Decimal

import pytest
from django.db import connection, transaction
from django.db.transaction import TransactionManagementError
from rest_framework.test import APIClient

from apps.auth.models import User
from apps.inventory.models import BranchInventory, InventoryMovement
from apps.inventory.services import stock_service
from core.enums import MovementType
from core.exceptions import (
    BranchAccessDeniedError,
    DomainError,
    InactiveProductError,
    InsufficientStockError,
)
from tests.factories import (
    LAS_AMERICAS,
    VILLA_LIBERTAD,
    BranchInventoryFactory,
    ProductFactory,
    SaleFactory,
    UserFactory,
)

pytestmark = pytest.mark.django_db

VL = VILLA_LIBERTAD
INVENTORY_URL = "/api/v1/inventory/"
MOVEMENTS_URL = "/api/v1/inventory/movements/"


def stock_of(inventory: BranchInventory) -> Decimal:
    inventory.refresh_from_db()
    return inventory.current_stock


# --- Entradas, mermas y ajustes ---------------------------------------------


def test_entry_increases_stock_and_writes_kardex(supervisor: User) -> None:
    inventory = BranchInventoryFactory(current_stock=Decimal("10.000"))

    movement = stock_service.register_entry(
        branch=VL,
        product_id=inventory.product_id,
        quantity=Decimal("2.5"),
        user=supervisor,
        notes=" Factura 123 ",
    )

    assert stock_of(inventory) == Decimal("12.500")
    assert movement.movement_type == MovementType.ENTRY
    assert movement.quantity == Decimal("2.500")
    assert (movement.stock_before, movement.stock_after) == (Decimal("10.000"), Decimal("12.500"))
    assert movement.user == supervisor
    assert movement.notes == "Factura 123"
    assert movement.sale is None


def test_entry_creates_missing_inventory_row(supervisor: User) -> None:
    product = ProductFactory()

    movement = stock_service.register_entry(
        branch=VL, product_id=product.pk, quantity=Decimal("4"), user=supervisor
    )

    assert movement.stock_before == 0
    assert BranchInventory.objects.get(product=product, branch=VL).current_stock == Decimal("4")


def test_entry_rejects_inactive_and_unknown_products(supervisor: User) -> None:
    inactive = ProductFactory(active=False)

    with pytest.raises(InactiveProductError):
        stock_service.register_entry(
            branch=VL, product_id=inactive.pk, quantity=Decimal("1"), user=supervisor
        )
    with pytest.raises(DomainError) as exc_info:
        stock_service.register_entry(
            branch=VL, product_id=999_999, quantity=Decimal("1"), user=supervisor
        )
    assert exc_info.value.code == "product_not_found"


@pytest.mark.parametrize("quantity", ["0", "-1", "0.0004"])
def test_quantity_must_be_positive(supervisor: User, quantity: str) -> None:
    inventory = BranchInventoryFactory()

    for operation in (stock_service.register_entry, stock_service.register_waste):
        with pytest.raises(DomainError) as exc_info:
            operation(
                branch=VL,
                product_id=inventory.product_id,
                quantity=Decimal(quantity),
                user=supervisor,
            )
        assert exc_info.value.code == "invalid_quantity"
    assert not InventoryMovement.objects.exists()


def test_waste_decreases_stock(supervisor: User) -> None:
    inventory = BranchInventoryFactory(current_stock=Decimal("10.000"))

    movement = stock_service.register_waste(
        branch=VL, product_id=inventory.product_id, quantity=Decimal("10"), user=supervisor
    )

    assert stock_of(inventory) == Decimal("0.000")
    assert movement.movement_type == MovementType.WASTE
    assert movement.quantity == Decimal("10.000")
    assert (movement.stock_before, movement.stock_after) == (Decimal("10.000"), Decimal("0.000"))


def test_waste_beyond_stock_fails_and_changes_nothing(supervisor: User) -> None:
    inventory = BranchInventoryFactory(current_stock=Decimal("10.000"))

    with pytest.raises(InsufficientStockError) as exc_info:
        stock_service.register_waste(
            branch=VL, product_id=inventory.product_id, quantity=Decimal("10.001"), user=supervisor
        )

    assert exc_info.value.status_code == 422
    assert exc_info.value.meta == {
        "items": [
            {"product_id": inventory.product_id, "requested": "10.001", "available": "10.000"}
        ]
    }
    assert stock_of(inventory) == Decimal("10.000")
    assert not InventoryMovement.objects.exists()


def test_waste_without_inventory_row_fails(supervisor: User) -> None:
    with pytest.raises(InsufficientStockError):
        stock_service.register_waste(
            branch=VL, product_id=ProductFactory().pk, quantity=Decimal("1"), user=supervisor
        )


@pytest.mark.parametrize(
    ("counted", "quantity"), [("7.250", "2.750"), ("13.000", "3.000"), ("0", "10.000")]
)
def test_adjustment_sets_stock_to_counted_value(
    supervisor: User, counted: str, quantity: str
) -> None:
    inventory = BranchInventoryFactory(current_stock=Decimal("10.000"))

    movement = stock_service.register_adjustment(
        branch=VL, product_id=inventory.product_id, counted_stock=Decimal(counted), user=supervisor
    )

    assert stock_of(inventory) == Decimal(counted)
    assert movement.movement_type == MovementType.ADJUSTMENT
    assert movement.quantity == Decimal(quantity)  # siempre la magnitud
    assert movement.stock_before == Decimal("10.000")
    assert movement.stock_after == Decimal(counted)


def test_adjustment_without_difference_does_nothing(supervisor: User) -> None:
    inventory = BranchInventoryFactory(current_stock=Decimal("10.000"))

    movement = stock_service.register_adjustment(
        branch=VL, product_id=inventory.product_id, counted_stock=Decimal("10"), user=supervisor
    )

    assert movement is None
    assert not InventoryMovement.objects.exists()


def test_adjustment_rejects_negative_count(supervisor: User) -> None:
    inventory = BranchInventoryFactory()

    with pytest.raises(DomainError) as exc_info:
        stock_service.register_adjustment(
            branch=VL,
            product_id=inventory.product_id,
            counted_stock=Decimal("-1"),
            user=supervisor,
        )
    assert exc_info.value.code == "invalid_quantity"


def test_user_cannot_move_stock_of_another_branch(supervisor: User) -> None:
    inventory = BranchInventoryFactory(branch=LAS_AMERICAS)

    with pytest.raises(BranchAccessDeniedError):
        stock_service.register_entry(
            branch=LAS_AMERICAS,
            product_id=inventory.product_id,
            quantity=Decimal("1"),
            user=supervisor,
        )
    assert stock_of(inventory) == Decimal("10.000")


def test_branches_keep_independent_stock(manager: User) -> None:
    here = BranchInventoryFactory(branch=VL, current_stock=Decimal("10"))
    there = BranchInventoryFactory(
        product=here.product, branch=LAS_AMERICAS, current_stock=Decimal("10")
    )

    stock_service.register_waste(
        branch=VL, product_id=here.product_id, quantity=Decimal("3"), user=manager
    )

    assert stock_of(here) == Decimal("7.000")
    assert stock_of(there) == Decimal("10.000")


# --- Consultas --------------------------------------------------------------


def test_low_stock_and_minimum(supervisor: User) -> None:
    low = BranchInventoryFactory(current_stock=Decimal("2"), minimum_stock=Decimal("2"))
    BranchInventoryFactory(current_stock=Decimal("2.001"), minimum_stock=Decimal("2"))
    BranchInventoryFactory(
        product=ProductFactory(active=False), current_stock=Decimal("0"), minimum_stock=Decimal("5")
    )
    BranchInventoryFactory(branch=LAS_AMERICAS, current_stock=Decimal("0"))

    assert list(stock_service.get_low_stock(VL)) == [low]
    assert stock_service.get_branch_inventory(VL).count() == 3

    updated = stock_service.set_minimum_stock(VL, low.product_id, Decimal("1.5"))
    assert updated.minimum_stock == Decimal("1.500")
    assert list(stock_service.get_low_stock(VL)) == []
    assert not InventoryMovement.objects.exists()  # el mínimo no genera Kardex
    with pytest.raises(DomainError):
        stock_service.set_minimum_stock(VL, low.product_id, Decimal("-1"))
    with pytest.raises(DomainError):
        stock_service.set_minimum_stock(VL, 999_999, Decimal("1"))


# --- Soporte a ventas -------------------------------------------------------


@pytest.mark.django_db(transaction=True)
def test_lock_and_validate_requires_a_transaction() -> None:
    inventory = BranchInventoryFactory()

    with pytest.raises(TransactionManagementError):
        stock_service.lock_and_validate_stock(VL, {inventory.product_id: Decimal("1")})


@pytest.mark.django_db(transaction=True)
def test_lock_and_validate_reports_every_shortage() -> None:
    enough = BranchInventoryFactory(current_stock=Decimal("5"))
    short = BranchInventoryFactory(current_stock=Decimal("1"))
    unstocked = ProductFactory()
    quantities = {
        unstocked.pk: Decimal("1.000"),
        short.product_id: Decimal("1.500"),
        enough.product_id: Decimal("5.000"),
    }

    with pytest.raises(InsufficientStockError) as exc_info, transaction.atomic():
        stock_service.lock_and_validate_stock(VL, quantities)

    assert exc_info.value.meta == {
        "items": [
            {"product_id": short.product_id, "requested": "1.500", "available": "1.000"},
            {"product_id": unstocked.pk, "requested": "1.000", "available": "0"},
        ]
    }


def test_discount_for_sale(supervisor: User) -> None:
    first = BranchInventoryFactory(current_stock=Decimal("10.000"))
    second = BranchInventoryFactory(current_stock=Decimal("3.000"))
    sale = SaleFactory(cash_session__user=supervisor)
    quantities = {second.product_id: Decimal("3.000"), first.product_id: Decimal("2.500")}

    with transaction.atomic():
        locked = stock_service.lock_and_validate_stock(VL, quantities)
        movements = stock_service.discount_for_sale(
            sale=sale, locked_inventory=locked, quantities=quantities, user=supervisor
        )

    assert stock_of(first) == Decimal("7.500")
    assert stock_of(second) == Decimal("0.000")
    assert [m.product_id for m in movements] == sorted(quantities)
    saved = InventoryMovement.objects.get(product=first.product)
    assert saved.movement_type == MovementType.SALE
    assert saved.sale == sale
    assert saved.branch == sale.branch
    assert (saved.quantity, saved.stock_before, saved.stock_after) == (
        Decimal("2.500"),
        Decimal("10.000"),
        Decimal("7.500"),
    )


@pytest.mark.django_db(transaction=True)
def test_concurrent_wastes_cannot_oversell() -> None:
    inventory = BranchInventoryFactory(current_stock=Decimal("10.000"))
    user = UserFactory()
    barrier = threading.Barrier(2)
    outcomes: list[str] = []

    def worker() -> None:
        try:
            barrier.wait(timeout=10)
            stock_service.register_waste(
                branch=VL, product_id=inventory.product_id, quantity=Decimal("6"), user=user
            )
            outcomes.append("ok")
        except InsufficientStockError:
            outcomes.append("insufficient")
        finally:
            connection.close()

    threads = [threading.Thread(target=worker) for _ in range(2)]
    for thread in threads:
        thread.start()
    for thread in threads:
        thread.join(timeout=30)

    assert sorted(outcomes) == ["insufficient", "ok"]
    assert stock_of(inventory) == Decimal("4.000")
    assert InventoryMovement.objects.count() == 1


# --- API --------------------------------------------------------------------


def test_stock_flow_through_api(api_client: APIClient, supervisor: User) -> None:
    inventory = BranchInventoryFactory(current_stock=Decimal("10"), minimum_stock=Decimal("8"))
    api_client.force_authenticate(supervisor)
    base = {"product_id": inventory.product_id}

    entry = api_client.post(
        MOVEMENTS_URL, {**base, "movement_type": "ENTRY", "quantity": "5"}, format="json"
    )
    assert entry.status_code == 201
    assert entry.data["stock_after"] == "15.000"
    assert entry.data["branch"] == VL

    waste = api_client.post(
        MOVEMENTS_URL, {**base, "movement_type": "WASTE", "quantity": "99"}, format="json"
    )
    assert waste.status_code == 422
    assert waste.data["code"] == "insufficient_stock"

    adjustment = {**base, "movement_type": "ADJUSTMENT", "quantity": "7"}
    assert api_client.post(MOVEMENTS_URL, adjustment, format="json").status_code == 201
    assert api_client.post(MOVEMENTS_URL, adjustment, format="json").status_code == 204
    sale_attempt = api_client.post(
        MOVEMENTS_URL, {**base, "movement_type": "SALE", "quantity": "1"}, format="json"
    )
    assert sale_attempt.status_code == 400

    listing = api_client.get(INVENTORY_URL)
    assert listing.data["count"] == 1
    assert listing.data["results"][0]["current_stock"] == "7.000"
    assert listing.data["results"][0]["product_name"] == inventory.product.name
    assert api_client.get(f"{INVENTORY_URL}low-stock/").data["count"] == 1

    kardex = api_client.get(MOVEMENTS_URL)
    assert [row["movement_type"] for row in kardex.data["results"]] == ["ADJUSTMENT", "ENTRY"]
    assert api_client.get(MOVEMENTS_URL, {"movement_type": "ENTRY"}).data["count"] == 1
    assert api_client.get(MOVEMENTS_URL, {"product": 999999}).data["count"] == 0
    assert api_client.get(MOVEMENTS_URL, {"movement_type": "NOPE"}).status_code == 400


def test_api_branch_scope_and_roles(api_client: APIClient, supervisor: User, manager: User) -> None:
    inventory = BranchInventoryFactory(branch=LAS_AMERICAS)
    minimum_url = f"{INVENTORY_URL}{inventory.product_id}/minimum-stock/"

    api_client.force_authenticate(supervisor)
    assert api_client.get(INVENTORY_URL, {"branch": "LAS_AMERICAS"}).status_code == 403
    assert api_client.get(MOVEMENTS_URL, {"branch": "LAS_AMERICAS"}).status_code == 403
    denied = api_client.post(
        MOVEMENTS_URL,
        {
            "product_id": inventory.product_id,
            "branch": "LAS_AMERICAS",
            "movement_type": "ENTRY",
            "quantity": "1",
        },
        format="json",
    )
    assert denied.status_code == 403
    assert api_client.patch(minimum_url, {"minimum_stock": "1"}, format="json").status_code == 403

    api_client.force_authenticate(manager)
    assert api_client.get(INVENTORY_URL).data["code"] == "branch_required"
    assert api_client.get(INVENTORY_URL, {"branch": "LAS_AMERICAS"}).data["count"] == 1
    updated = api_client.patch(
        minimum_url, {"branch": "LAS_AMERICAS", "minimum_stock": "4.5"}, format="json"
    )
    assert updated.status_code == 200
    assert updated.data["minimum_stock"] == "4.500"
