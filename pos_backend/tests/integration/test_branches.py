from decimal import Decimal

import pytest
from django.utils import timezone
from rest_framework.test import APIClient

from apps.auth.models import User
from apps.auth.services import user_service
from apps.branches.models import Branch
from apps.branches.services import branch_service
from apps.cash_sessions.services import cash_session_service
from apps.inventory.models import BranchInventory
from apps.inventory.services import product_service
from core.branch_scope import resolve_branch
from core.enums import Role, UnitOfMeasure
from core.exceptions import DomainError
from tests.factories import (
    LAS_AMERICAS,
    VILLA_LIBERTAD,
    BranchFactory,
    CashSessionFactory,
    CategoryFactory,
    ProductFactory,
)

pytestmark = pytest.mark.django_db

BRANCHES_URL = "/api/v1/branches/"
INVENTORY_URL = "/api/v1/inventory/"
SESSIONS_URL = "/api/v1/cash-sessions/"


@pytest.fixture
def new_product() -> dict:
    """Datos de alta de un producto en una categoría activa."""
    return {
        "name": "Detergent",
        "category_id": CategoryFactory().pk,
        "unit_of_measure": UnitOfMeasure.LITER,
        "cost_price_usd": Decimal("1.20"),
        "sale_price_usd": Decimal("2.00"),
    }


@pytest.fixture
def single_branch() -> str:
    """Negocio con un solo local: solo queda activa VILLA_LIBERTAD."""
    Branch.objects.filter(code=LAS_AMERICAS).delete()
    return VILLA_LIBERTAD


def test_create_branch_normalizes_code_and_stocks_existing_products() -> None:
    products = [ProductFactory(), ProductFactory(active=False)]

    branch = branch_service.create_branch(code="  centro ", name="  Sede Centro ")

    assert (branch.code, branch.name, branch.active) == ("CENTRO", "Sede Centro", True)
    rows = BranchInventory.objects.filter(branch_id="CENTRO")
    assert {row.product_id for row in rows} == {product.pk for product in products}
    assert all(row.current_stock == 0 for row in rows)


@pytest.mark.parametrize(
    ("override", "code", "status_code"),
    [
        ({"code": "sede centro"}, "invalid_branch_code", 422),
        ({"code": "1CENTRO"}, "invalid_branch_code", 422),
        ({"code": "X" * 21}, "invalid_branch_code", 422),
        ({"name": "  "}, "invalid_branch_name", 422),
        ({"code": "villa_libertad"}, "branch_code_taken", 409),
    ],
)
def test_create_branch_validates_input(override: dict, code: str, status_code: int) -> None:
    with pytest.raises(DomainError) as exc_info:
        branch_service.create_branch(**{"code": "CENTRO", "name": "Centro", **override})

    assert exc_info.value.code == code
    assert exc_info.value.status_code == status_code
    assert Branch.objects.count() == 2


def test_new_products_are_stocked_only_in_active_branches(new_product: dict) -> None:
    branch_service.update_branch(LAS_AMERICAS, active=False)

    product = product_service.create_product(**new_product)

    rows = BranchInventory.objects.filter(product=product)
    assert {row.branch_id for row in rows} == {VILLA_LIBERTAD}


def test_reactivating_a_branch_completes_its_inventory(new_product: dict) -> None:
    branch_service.update_branch(LAS_AMERICAS, active=False)
    product = product_service.create_product(**new_product)

    branch = branch_service.update_branch(LAS_AMERICAS, active=True, name="Américas")

    assert (branch.active, branch.name) == (True, "Américas")
    assert BranchInventory.objects.filter(product=product, branch_id=LAS_AMERICAS).exists()


def test_branch_with_open_sessions_cannot_be_deactivated() -> None:
    session = CashSessionFactory(branch=LAS_AMERICAS)

    with pytest.raises(DomainError) as exc_info:
        branch_service.update_branch(LAS_AMERICAS, active=False)
    assert exc_info.value.code == "branch_has_open_sessions"
    assert exc_info.value.status_code == 409

    session.closed_at = timezone.now()
    session.save()
    assert branch_service.update_branch(LAS_AMERICAS, active=False).active is False


def test_inactive_or_unknown_branch_cannot_be_used(manager: User) -> None:
    branch_service.update_branch(LAS_AMERICAS, active=False)
    stranded = User(role=Role.SUPERVISOR, assigned_branch_id=LAS_AMERICAS)

    for user, requested in ((manager, LAS_AMERICAS), (manager, "NOWHERE"), (stranded, None)):
        with pytest.raises(DomainError) as exc_info:
            resolve_branch(user, requested)
        assert exc_info.value.code == "invalid_branch"
        assert exc_info.value.meta["allowed"] == [VILLA_LIBERTAD]


def test_manager_must_choose_when_there_are_several_branches(manager: User) -> None:
    with pytest.raises(DomainError) as exc_info:
        resolve_branch(manager, None)

    assert exc_info.value.code == "branch_required"
    assert exc_info.value.meta["allowed"] == [LAS_AMERICAS, VILLA_LIBERTAD]


def test_single_branch_business_never_needs_to_choose(manager: User, single_branch: str) -> None:
    assert resolve_branch(manager, None) == single_branch

    session = cash_session_service.open_session(
        user=manager, branch=None, opening_float=Decimal("10.00")
    )
    assert session.branch_id == single_branch


def test_single_branch_business_through_api(
    api_client: APIClient, manager: User, single_branch: str
) -> None:
    ProductFactory()
    branch_service.create_branch(code="TEMP", name="Temporal")
    branch_service.update_branch("TEMP", active=False)
    api_client.force_authenticate(manager)

    assert api_client.get(INVENTORY_URL).data["count"] == 0
    opened = api_client.post(SESSIONS_URL, {"opening_float": "5.00"}, format="json")
    assert opened.status_code == 201
    assert opened.data["branch"] == single_branch


def test_business_without_branches(manager: User) -> None:
    Branch.objects.all().delete()

    with pytest.raises(DomainError) as exc_info:
        resolve_branch(manager, None)

    assert exc_info.value.code == "no_branches"
    assert exc_info.value.status_code == 409


def test_user_must_be_assigned_to_an_active_branch(manager: User, supervisor: User) -> None:
    new_user = {
        "username": "cperez",
        "password": "Caja-segura-2026",
        "full_name": "Carlos Perez",
        "role": Role.SUPERVISOR,
    }
    with pytest.raises(DomainError) as exc_info:
        user_service.create_user(**new_user, assigned_branch="NOWHERE")
    assert exc_info.value.code == "invalid_branch"

    with pytest.raises(DomainError) as exc_info:
        user_service.update_user(supervisor.pk, manager, assigned_branch="NOWHERE")
    assert exc_info.value.code == "invalid_branch"

    moved = user_service.update_user(supervisor.pk, manager, assigned_branch=LAS_AMERICAS)
    moved.refresh_from_db()
    assert moved.assigned_branch_id == LAS_AMERICAS


def test_branch_lifecycle_through_api(api_client: APIClient, manager: User) -> None:
    api_client.force_authenticate(manager)

    created = api_client.post(BRANCHES_URL, {"code": "centro", "name": "Centro"}, format="json")
    assert created.status_code == 201
    assert created.data == {"code": "CENTRO", "name": "Centro", "active": True}

    duplicate = api_client.post(BRANCHES_URL, {"code": "CENTRO", "name": "Otra"}, format="json")
    assert duplicate.status_code == 409
    assert duplicate.data["code"] == "branch_code_taken"

    detail_url = f"{BRANCHES_URL}CENTRO/"
    assert api_client.get(detail_url).data["name"] == "Centro"
    updated = api_client.patch(detail_url, {"name": "Sede", "active": False}, format="json")
    assert updated.status_code == 200
    assert updated.data == {"code": "CENTRO", "name": "Sede", "active": False}

    assert api_client.get(BRANCHES_URL).data["count"] == 3
    assert api_client.get(BRANCHES_URL, {"active": "true"}).data["count"] == 2
    assert api_client.get(f"{BRANCHES_URL}NOWHERE/").status_code == 404
    assert api_client.get(f"/api/v1/users/{manager.pk}/").data["assigned_branch"] is None


def test_only_managers_manage_branches(api_client: APIClient, supervisor: User) -> None:
    BranchFactory(code="CENTRO")
    detail_url = f"{BRANCHES_URL}CENTRO/"

    assert api_client.get(BRANCHES_URL).status_code == 401
    api_client.force_authenticate(supervisor)

    assert api_client.get(BRANCHES_URL).data["count"] == 3
    assert api_client.get(detail_url).status_code == 200
    payload = {"code": "NORTE", "name": "Norte"}
    assert api_client.post(BRANCHES_URL, payload, format="json").status_code == 403
    assert api_client.patch(detail_url, {"active": False}, format="json").status_code == 403
    assert api_client.get("/api/v1/auth/me/").data["assigned_branch"] == VILLA_LIBERTAD
