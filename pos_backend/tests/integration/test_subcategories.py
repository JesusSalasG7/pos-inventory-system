import pytest
from rest_framework.test import APIClient

from apps.auth.models import User
from apps.inventory.models import Subcategory
from apps.inventory.services import category_service, product_service, subcategory_service
from core.exceptions import DomainError
from tests.factories import CategoryFactory, ProductFactory, SubcategoryFactory

pytestmark = pytest.mark.django_db

SUBCATEGORIES_URL = "/api/v1/subcategories/"
PRODUCTS_URL = "/api/v1/products/"


def test_create_subcategory_trims_the_name() -> None:
    category = CategoryFactory(name="Limpieza")

    subcategory = subcategory_service.create_subcategory(
        category_id=category.pk, name="  Detergentes "
    )

    assert (subcategory.name, subcategory.category_id, subcategory.active) == (
        "Detergentes",
        category.pk,
        True,
    )


def test_subcategory_name_is_unique_only_inside_its_category() -> None:
    cleaning = CategoryFactory(name="Limpieza")
    aromas = CategoryFactory(name="Aromas")
    SubcategoryFactory(category=cleaning, name="Concentrados")

    with pytest.raises(DomainError) as exc_info:
        subcategory_service.create_subcategory(category_id=cleaning.pk, name="CONCENTRADOS")
    assert (exc_info.value.code, exc_info.value.status_code) == ("subcategory_name_taken", 409)

    # Otra categoría sí puede repetir el nombre.
    other = subcategory_service.create_subcategory(category_id=aromas.pk, name="Concentrados")
    assert other.category_id == aromas.pk


def test_create_subcategory_validates_name_and_category() -> None:
    category = CategoryFactory(name="Limpieza")

    with pytest.raises(DomainError) as exc_info:
        subcategory_service.create_subcategory(category_id=category.pk, name="   ")
    assert exc_info.value.code == "invalid_subcategory_name"

    with pytest.raises(DomainError) as exc_info:
        subcategory_service.create_subcategory(category_id=999_999, name="X")
    assert exc_info.value.code == "category_not_found"

    category_service.update_category(category.pk, active=False)
    with pytest.raises(DomainError) as exc_info:
        subcategory_service.create_subcategory(category_id=category.pk, name="X")
    assert exc_info.value.code == "inactive_category"
    assert not Subcategory.objects.exists()


def test_update_subcategory() -> None:
    category = CategoryFactory(name="Limpieza")
    subcategory = SubcategoryFactory(category=category, name="Jabones")
    SubcategoryFactory(category=category, name="Cloros")

    assert subcategory_service.update_subcategory(subcategory.pk, name=" Jabón ").name == "Jabón"
    # Conservar su propio nombre no cuenta como repetido.
    assert subcategory_service.update_subcategory(subcategory.pk, name="JABÓN").name == "JABÓN"
    with pytest.raises(DomainError) as exc_info:
        subcategory_service.update_subcategory(subcategory.pk, name="cloros")
    assert exc_info.value.code == "subcategory_name_taken"
    # La categoría de una subcategoría no se cambia.
    with pytest.raises(ValueError):
        subcategory_service.update_subcategory(subcategory.pk, category_id=5)


def test_get_unknown_subcategory() -> None:
    with pytest.raises(DomainError) as exc_info:
        subcategory_service.get_subcategory(999_999)

    assert (exc_info.value.code, exc_info.value.status_code) == ("subcategory_not_found", 404)


def test_product_subcategory_must_be_active_and_of_its_category() -> None:
    cleaning = CategoryFactory(name="Limpieza")
    other = SubcategoryFactory(category=CategoryFactory(name="Aromas"))
    inactive = SubcategoryFactory(category=cleaning, active=False)
    product = ProductFactory(category=cleaning)

    for subcategory, code in [
        (other, "subcategory_category_mismatch"),
        (inactive, "inactive_subcategory"),
    ]:
        with pytest.raises(DomainError) as exc_info:
            product_service.update_product(product.pk, subcategory_id=subcategory.pk)
        assert (exc_info.value.code, exc_info.value.status_code) == (code, 422)

    with pytest.raises(DomainError) as exc_info:
        product_service.update_product(product.pk, subcategory_id=999_999)
    assert exc_info.value.code == "subcategory_not_found"
    product.refresh_from_db()
    assert product.subcategory_id is None


def test_changing_the_category_drops_the_old_subcategory() -> None:
    cleaning = CategoryFactory(name="Limpieza")
    aromas = CategoryFactory(name="Aromas")
    soaps = SubcategoryFactory(category=cleaning)
    sprays = SubcategoryFactory(category=aromas)
    product = ProductFactory(category=cleaning, subcategory=soaps)

    # Mandar la subcategoría vieja junto a la categoría nueva no cuadra.
    with pytest.raises(DomainError) as exc_info:
        product_service.update_product(product.pk, category_id=aromas.pk, subcategory_id=soaps.pk)
    assert exc_info.value.code == "subcategory_category_mismatch"

    moved = product_service.update_product(product.pk, category_id=aromas.pk)
    assert (moved.category_id, moved.subcategory_id) == (aromas.pk, None)

    both = product_service.update_product(
        product.pk, category_id=cleaning.pk, subcategory_id=soaps.pk
    )
    assert (both.category_id, both.subcategory_id) == (cleaning.pk, soaps.pk)
    assert product_service.update_product(product.pk, subcategory_id=None).subcategory_id is None
    assert sprays.products.count() == 0


def test_product_keeps_its_subcategory_when_it_is_deactivated() -> None:
    subcategory = SubcategoryFactory()
    product = ProductFactory(category=subcategory.category, subcategory=subcategory)

    subcategory_service.update_subcategory(subcategory.pk, active=False)

    # Editar otro dato, o reenviar la misma subcategoría, no la quita.
    updated = product_service.update_product(
        product.pk, name="Otro nombre", subcategory_id=subcategory.pk
    )
    assert updated.subcategory_id == subcategory.pk


def test_manager_manages_subcategories_through_api(api_client: APIClient, manager: User) -> None:
    category = CategoryFactory(name="Limpieza")
    SubcategoryFactory(category=CategoryFactory(name="Aromas"))
    api_client.force_authenticate(manager)

    created = api_client.post(
        SUBCATEGORIES_URL, {"category": category.pk, "name": "Detergentes"}, format="json"
    )
    assert created.status_code == 201
    assert created.data == {
        "id": created.data["id"],
        "category": category.pk,
        "name": "Detergentes",
        "active": True,
    }
    detail_url = f"{SUBCATEGORIES_URL}{created.data['id']}/"

    duplicated = api_client.post(
        SUBCATEGORIES_URL, {"category": category.pk, "name": "detergentes"}, format="json"
    )
    assert duplicated.status_code == 409
    patched = api_client.patch(detail_url, {"name": "Jabones", "active": False}, format="json")
    assert (patched.data["name"], patched.data["active"]) == ("Jabones", False)
    assert api_client.get(detail_url).data["name"] == "Jabones"
    assert api_client.get(SUBCATEGORIES_URL).data["count"] == 2
    assert api_client.get(SUBCATEGORIES_URL, {"category": category.pk}).data["count"] == 1
    listed = api_client.get(SUBCATEGORIES_URL, {"category": category.pk, "active": "true"})
    assert listed.data["count"] == 0
    assert api_client.get(SUBCATEGORIES_URL, {"category": "abc"}).status_code == 400
    assert api_client.get(f"{SUBCATEGORIES_URL}999999/").status_code == 404


def test_supervisor_reads_but_cannot_write_subcategories(
    api_client: APIClient, supervisor: User
) -> None:
    subcategory = SubcategoryFactory()
    api_client.force_authenticate(supervisor)

    assert api_client.get(SUBCATEGORIES_URL).status_code == 200
    payload = {"category": subcategory.category_id, "name": "X"}
    assert api_client.post(SUBCATEGORIES_URL, payload, format="json").status_code == 403
    detail_url = f"{SUBCATEGORIES_URL}{subcategory.pk}/"
    assert api_client.patch(detail_url, {}, format="json").status_code == 403


def test_products_carry_and_filter_by_subcategory(api_client: APIClient, manager: User) -> None:
    category = CategoryFactory(name="Limpieza")
    subcategory = SubcategoryFactory(category=category, name="Detergentes")
    plain = ProductFactory(category=category)
    api_client.force_authenticate(manager)

    # Un producto sin subcategoría la devuelve como null.
    data = api_client.get(f"{PRODUCTS_URL}{plain.pk}/").data
    assert (data["subcategory"], data["subcategory_name"]) == (None, None)

    created = api_client.post(
        PRODUCTS_URL,
        {
            "name": "Detergent",
            "category": category.pk,
            "subcategory": subcategory.pk,
            "unit_of_measure": "LITER",
            "cost_price_usd": "1.20",
            "sale_price_usd": "2.00",
        },
        format="json",
    )
    assert created.status_code == 201
    assert (created.data["subcategory"], created.data["subcategory_name"]) == (
        subcategory.pk,
        "Detergentes",
    )
    assert api_client.get(PRODUCTS_URL, {"subcategory": subcategory.pk}).data["count"] == 1

    cleared = api_client.patch(
        f"{PRODUCTS_URL}{created.data['id']}/", {"subcategory": None}, format="json"
    )
    assert (cleared.status_code, cleared.data["subcategory"]) == (200, None)
