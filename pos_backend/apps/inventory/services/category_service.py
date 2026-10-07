"""Reglas de negocio de las categorías del catálogo."""

from django.db import IntegrityError, transaction
from django.db.models import QuerySet

from apps.inventory.models import Category
from apps.inventory.repositories import category_repository
from core.exceptions import DomainError, NotFoundError

EDITABLE_FIELDS = frozenset({"name", "icon", "active"})


def list_categories(*, only_active: bool = False) -> QuerySet[Category]:
    """Lista las categorías ordenadas por nombre."""
    return category_repository.list_categories(only_active=only_active)


def get_category(category_id: int) -> Category:
    """Devuelve la categoría o lanza NotFoundError `category_not_found` (404)."""
    category = category_repository.get_by_id(category_id)
    if category is None:
        raise NotFoundError(
            "La categoría no existe.",
            code="category_not_found",
            meta={"category_id": category_id},
        )
    return category


def require_active(category_id: int) -> Category:
    """Devuelve la categoría si se le pueden asignar productos.

    Lanza `category_not_found` (404) si no existe e `inactive_category` (422)
    si está desactivada. Lo usa `product_service` al crear o recategorizar.
    """
    category = get_category(category_id)
    if not category.active:
        raise DomainError(
            "La categoría está inactiva.",
            code="inactive_category",
            status_code=422,
            meta={"category_id": category_id},
        )
    return category


def create_category(*, name: str, icon: str = "") -> Category:
    """Crea una categoría activa. El nombre no se repite, sin distinguir mayúsculas.

    `icon` es el sticker (emoji) elegido por el MANAGER; vacío deja que la app
    le asigne uno.
    """
    name = _clean_name(name)
    try:
        with transaction.atomic():
            return category_repository.create(name=name, icon=icon.strip())
    except IntegrityError as exc:
        raise _name_taken(name) from exc


def update_category(category_id: int, **fields: object) -> Category:
    """Cambia el nombre, el sticker o el estado de la categoría.

    Las categorías nunca se borran: se desactivan con `active`. Una categoría
    inactiva conserva sus productos, pero no admite productos nuevos.
    """
    unknown = fields.keys() - EDITABLE_FIELDS
    if unknown:
        raise ValueError(f"Campos no editables: {sorted(unknown)}")

    category = get_category(category_id)
    if "name" in fields:
        fields["name"] = _clean_name(str(fields["name"]), exclude_id=category.pk)
    if "icon" in fields:
        fields["icon"] = str(fields["icon"]).strip()
    if not fields:
        return category
    try:
        with transaction.atomic():
            return category_repository.update(category, **fields)
    except IntegrityError as exc:
        raise _name_taken(str(fields.get("name", category.name))) from exc


def _clean_name(name: str, *, exclude_id: int | None = None) -> str:
    name = name.strip()
    if not name:
        raise DomainError(
            "El nombre de la categoría es obligatorio.",
            code="invalid_category_name",
            status_code=422,
        )
    if category_repository.exists_by_name(name, exclude_id=exclude_id):
        raise _name_taken(name)
    return name


def _name_taken(name: str) -> DomainError:
    return DomainError(
        "Ya existe una categoría con ese nombre.",
        code="category_name_taken",
        status_code=409,
        meta={"name": name},
    )
