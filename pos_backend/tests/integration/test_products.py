from decimal import Decimal

import pytest
from rest_framework.test import APIClient

from apps.auth.models import User
from apps.inventory.models import BranchInventory, Product
from apps.inventory.services import category_service, product_service
from core.enums import UnitOfMeasure
from core.exceptions import DomainError, InactiveProductError
from tests.factories import LAS_AMERICAS, VILLA_LIBERTAD, CategoryFactory, ProductFactory

pytestmark = pytest.mark.django_db

PRODUCTS_URL = "/api/v1/products/"


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


def test_create_product_creates_zero_stock_in_every_branch(new_product: dict) -> None:
    product = product_service.create_product(**{**new_product, "name": "  Detergent  "})

    assert product.name == "Detergent"
    assert product.active
    rows = BranchInventory.objects.filter(product=product)
    assert {row.branch_id for row in rows} == {VILLA_LIBERTAD, LAS_AMERICAS}
    assert all(row.current_stock == 0 for row in rows)


def test_product_name_must_be_unique_ignoring_case(new_product: dict) -> None:
    product_service.create_product(**new_product)

    with pytest.raises(DomainError) as exc_info:
        product_service.create_product(**{**new_product, "name": "DETERGENT"})

    assert exc_info.value.code == "product_name_taken"
    assert exc_info.value.status_code == 409
    assert Product.objects.count() == 1


@pytest.mark.parametrize(
    ("override", "code"),
    [
        ({"name": "   "}, "invalid_name"),
        ({"cost_price_usd": Decimal("-0.01")}, "invalid_price"),
        ({"sale_price_usd": Decimal("-1")}, "invalid_price"),
    ],
)
def test_create_product_validates_input(override: dict, code: str, new_product: dict) -> None:
    with pytest.raises(DomainError) as exc_info:
        product_service.create_product(**{**new_product, **override})

    assert exc_info.value.code == code
    assert not Product.objects.exists()
    assert not BranchInventory.objects.exists()


def test_get_unknown_product() -> None:
    with pytest.raises(DomainError) as exc_info:
        product_service.get_product(999_999)

    assert exc_info.value.code == "product_not_found"
    assert exc_info.value.status_code == 404


def test_update_product() -> None:
    product = ProductFactory(name="Soap", sale_price_usd=Decimal("1.50"))
    other = ProductFactory(name="Bleach")

    updated = product_service.update_product(
        product.pk, name="Soap", sale_price_usd=Decimal("1.75")
    )  # conservar su propio nombre no cuenta como repetido

    updated.refresh_from_db()
    assert updated.sale_price_usd == Decimal("1.75")
    with pytest.raises(DomainError) as exc_info:
        product_service.update_product(product.pk, name=other.name.lower())
    assert exc_info.value.code == "product_name_taken"
    with pytest.raises(DomainError):
        product_service.update_product(product.pk, cost_price_usd=Decimal("-1"))
    with pytest.raises(ValueError):
        product_service.update_product(product.pk, active=False)


def test_toggle_active() -> None:
    product = ProductFactory()

    assert product_service.toggle_active(product.pk).active is False
    assert product_service.toggle_active(product.pk).active is True


def test_list_products_filters() -> None:
    powders = CategoryFactory(name="Polvos")
    soap = ProductFactory(name="Soap", category=powders)
    bleach = ProductFactory(name="Bleach")
    retired = ProductFactory(name="Old soap", active=False)

    assert list(product_service.list_products()) == [bleach, retired, soap]
    assert list(product_service.list_products(only_active=True)) == [bleach, soap]
    assert list(product_service.list_products(search="SOAP")) == [retired, soap]
    assert list(product_service.list_products(category_id=powders.pk)) == [soap]


def test_get_active_products() -> None:
    active = ProductFactory()
    inactive = ProductFactory(active=False)

    assert product_service.get_active_products([active.pk, active.pk]) == {active.pk: active}
    with pytest.raises(InactiveProductError) as exc_info:
        product_service.get_active_products([active.pk, inactive.pk, 999_999])
    assert exc_info.value.meta == {"product_ids": [inactive.pk, 999_999]}


def test_manager_manages_catalog_through_api(
    api_client: APIClient, manager: User, new_product: dict
) -> None:
    api_client.force_authenticate(manager)
    payload = {**new_product, "cost_price_usd": "1.20", "sale_price_usd": "2.00"}
    payload["category"] = payload.pop("category_id")

    created = api_client.post(PRODUCTS_URL, payload, format="json")
    assert created.status_code == 201
    detail_url = f"{PRODUCTS_URL}{created.data['id']}/"

    assert api_client.post(PRODUCTS_URL, payload, format="json").status_code == 409
    patched = api_client.patch(detail_url, {"sale_price_usd": "2.50"}, format="json")
    assert patched.status_code == 200
    assert patched.data["sale_price_usd"] == "2.50"
    assert patched.data["name"] == "Detergent"
    assert patched.data["category"] == payload["category"]
    assert patched.data["category_name"] == "Líquidos"
    assert api_client.get(PRODUCTS_URL, {"category": payload["category"]}).data["count"] == 1
    assert api_client.get(PRODUCTS_URL, {"category": "abc"}).status_code == 400

    toggled = api_client.post(f"{detail_url}toggle-active/")
    assert toggled.data["active"] is False
    assert api_client.get(PRODUCTS_URL, {"active": "true"}).data["count"] == 0
    assert api_client.get(PRODUCTS_URL).data["count"] == 1
    assert api_client.get(f"{PRODUCTS_URL}999999/").status_code == 404


def test_supervisor_reads_but_cannot_write_catalog(api_client: APIClient, supervisor: User) -> None:
    product = ProductFactory()
    api_client.force_authenticate(supervisor)

    assert api_client.get(PRODUCTS_URL).status_code == 200
    assert api_client.get(f"{PRODUCTS_URL}{product.pk}/").status_code == 200
    assert api_client.post(PRODUCTS_URL, {}, format="json").status_code == 403
    assert api_client.patch(f"{PRODUCTS_URL}{product.pk}/", {}, format="json").status_code == 403
    assert api_client.post(f"{PRODUCTS_URL}{product.pk}/toggle-active/").status_code == 403


def test_product_needs_an_existing_active_category(new_product: dict) -> None:
    retired = CategoryFactory(name="Retired", active=False)

    with pytest.raises(DomainError) as exc_info:
        product_service.create_product(**{**new_product, "category_id": retired.pk})
    assert exc_info.value.code == "inactive_category"
    with pytest.raises(DomainError) as exc_info:
        product_service.create_product(**{**new_product, "category_id": 999_999})
    assert exc_info.value.code == "category_not_found"
    assert not Product.objects.exists()


def test_product_keeps_its_category_when_it_is_deactivated() -> None:
    category = CategoryFactory(name="Seasonal")
    other = CategoryFactory(name="Retired", active=False)
    product = ProductFactory(category=category)
    category_service.update_category(category.pk, active=False)

    # Editar otros campos, o reenviar la misma categoría, sigue permitido.
    updated = product_service.update_product(
        product.pk, category_id=category.pk, sale_price_usd=Decimal("3.00")
    )
    assert updated.category_id == category.pk
    with pytest.raises(DomainError) as exc_info:
        product_service.update_product(product.pk, category_id=other.pk)
    assert exc_info.value.code == "inactive_category"
