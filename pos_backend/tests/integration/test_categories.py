import pytest
from rest_framework.test import APIClient

from apps.auth.models import User
from apps.inventory.models import Category
from apps.inventory.services import category_service
from core.exceptions import DomainError
from tests.factories import CategoryFactory, ProductFactory

pytestmark = pytest.mark.django_db

CATEGORIES_URL = "/api/v1/categories/"


def test_there_are_no_default_categories() -> None:
    assert not Category.objects.exists()


def test_create_category_trims_the_name() -> None:
    category = category_service.create_category(name="  Aromatizantes ")

    assert (category.name, category.active) == ("Aromatizantes", True)


@pytest.mark.parametrize(
    ("name", "code", "status_code"),
    [
        ("   ", "invalid_category_name", 422),
        ("AROMAS", "category_name_taken", 409),
    ],
)
def test_create_category_validates_the_name(name: str, code: str, status_code: int) -> None:
    CategoryFactory(name="Aromas")
    before = Category.objects.count()

    with pytest.raises(DomainError) as exc_info:
        category_service.create_category(name=name)

    assert (exc_info.value.code, exc_info.value.status_code) == (code, status_code)
    assert Category.objects.count() == before


def test_update_category() -> None:
    category = CategoryFactory(name="Aromas")
    CategoryFactory(name="Polvos")

    renamed = category_service.update_category(category.pk, name=" Aromatizantes ")
    assert renamed.name == "Aromatizantes"
    # Conservar su propio nombre no cuenta como repetido.
    assert category_service.update_category(category.pk, name="aromatizantes").name == (
        "aromatizantes"
    )
    with pytest.raises(DomainError) as exc_info:
        category_service.update_category(category.pk, name="polvos")
    assert exc_info.value.code == "category_name_taken"
    with pytest.raises(ValueError):
        category_service.update_category(category.pk, id=5)


def test_deactivated_category_keeps_its_products() -> None:
    category = CategoryFactory(name="Aromas")
    product = ProductFactory(category=category)

    category_service.update_category(category.pk, active=False)

    product.refresh_from_db()
    assert product.category_id == category.pk
    assert list(category_service.list_categories(only_active=True).filter(pk=category.pk)) == []


def test_get_unknown_category() -> None:
    with pytest.raises(DomainError) as exc_info:
        category_service.get_category(999_999)

    assert (exc_info.value.code, exc_info.value.status_code) == ("category_not_found", 404)


def test_manager_manages_categories_through_api(api_client: APIClient, manager: User) -> None:
    api_client.force_authenticate(manager)

    created = api_client.post(CATEGORIES_URL, {"name": "Aromatizantes"}, format="json")
    assert created.status_code == 201
    assert created.data == {
        "id": created.data["id"],
        "name": "Aromatizantes",
        "icon": "",
        "active": True,
    }
    detail_url = f"{CATEGORIES_URL}{created.data['id']}/"

    assert api_client.post(CATEGORIES_URL, {"name": "aromatizantes"}).status_code == 409
    patched = api_client.patch(
        detail_url, {"name": "Aromas", "icon": "🌸", "active": False}, format="json"
    )
    assert patched.data == {
        "id": created.data["id"],
        "name": "Aromas",
        "icon": "🌸",
        "active": False,
    }
    assert api_client.get(detail_url).data["name"] == "Aromas"
    assert api_client.get(CATEGORIES_URL).data["count"] == 1
    assert api_client.get(CATEGORIES_URL, {"active": "true"}).data["count"] == 0
    assert api_client.get(f"{CATEGORIES_URL}999999/").status_code == 404


def test_supervisor_reads_but_cannot_write_categories(
    api_client: APIClient, supervisor: User
) -> None:
    category = CategoryFactory()
    api_client.force_authenticate(supervisor)

    assert api_client.get(CATEGORIES_URL).status_code == 200
    assert api_client.post(CATEGORIES_URL, {"name": "X"}, format="json").status_code == 403
    assert api_client.patch(f"{CATEGORIES_URL}{category.pk}/", {}, format="json").status_code == 403


def test_category_sticker_is_optional_and_can_be_cleared() -> None:
    automatic = category_service.create_category(name="Aromas")
    chosen = category_service.create_category(name="Limpieza", icon=" 🧽 ")

    assert (automatic.icon, chosen.icon) == ("", "🧽")
    assert category_service.update_category(chosen.pk, icon="").icon == ""


def test_products_carry_the_sticker_of_their_category(api_client: APIClient, manager: User) -> None:
    product = ProductFactory(category=CategoryFactory(name="Limpieza", icon="🧽"))
    api_client.force_authenticate(manager)

    data = api_client.get(f"/api/v1/products/{product.pk}/").data

    assert (data["category_name"], data["category_icon"]) == ("Limpieza", "🧽")
