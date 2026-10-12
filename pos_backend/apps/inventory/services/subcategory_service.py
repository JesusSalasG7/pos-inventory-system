"""Reglas de negocio de las subcategorías del catálogo."""

from django.db import IntegrityError, transaction
from django.db.models import QuerySet

from apps.inventory.models import Subcategory
from apps.inventory.repositories import subcategory_repository
from apps.inventory.services import category_service
from core.exceptions import DomainError, NotFoundError

EDITABLE_FIELDS = frozenset({"name", "active"})


def list_subcategories(
    *, only_active: bool = False, category_id: int | None = None
) -> QuerySet[Subcategory]:
    """Lista las subcategorías ordenadas por nombre, de una categoría o de todas."""
    return subcategory_repository.list_subcategories(
        only_active=only_active, category_id=category_id
    )


def get_subcategory(subcategory_id: int) -> Subcategory:
    """Devuelve la subcategoría o lanza NotFoundError `subcategory_not_found` (404)."""
    subcategory = subcategory_repository.get_by_id(subcategory_id)
    if subcategory is None:
        raise NotFoundError(
            "La subcategoría no existe.",
            code="subcategory_not_found",
            meta={"subcategory_id": subcategory_id},
        )
    return subcategory


def require_active_in_category(subcategory_id: int, category_id: int) -> Subcategory:
    """Devuelve la subcategoría si se le puede asignar un producto de esa categoría.

    Lanza `subcategory_not_found` (404) si no existe, `subcategory_category_mismatch`
    (422) si es de otra categoría e `inactive_subcategory` (422) si está
    desactivada. Lo usa `product_service` al crear o reclasificar.
    """
    subcategory = get_subcategory(subcategory_id)
    if subcategory.category_id != category_id:
        raise DomainError(
            "La subcategoría no pertenece a la categoría del producto.",
            code="subcategory_category_mismatch",
            status_code=422,
            meta={"subcategory_id": subcategory_id, "category_id": category_id},
        )
    if not subcategory.active:
        raise DomainError(
            "La subcategoría está inactiva.",
            code="inactive_subcategory",
            status_code=422,
            meta={"subcategory_id": subcategory_id},
        )
    return subcategory


def create_subcategory(*, category_id: int, name: str) -> Subcategory:
    """Crea una subcategoría activa dentro de una categoría activa.

    El nombre no se repite dentro de la misma categoría, sin distinguir mayúsculas.
    """
    category_service.require_active(category_id)
    name = _clean_name(category_id, name)
    try:
        with transaction.atomic():
            return subcategory_repository.create(category_id=category_id, name=name)
    except IntegrityError as exc:
        raise _name_taken(name) from exc


def update_subcategory(subcategory_id: int, **fields: object) -> Subcategory:
    """Cambia el nombre o el estado de la subcategoría.

    Las subcategorías nunca se borran: se desactivan con `active`. Una
    subcategoría inactiva conserva sus productos, pero no admite productos nuevos.
    """
    unknown = fields.keys() - EDITABLE_FIELDS
    if unknown:
        raise ValueError(f"Campos no editables: {sorted(unknown)}")

    subcategory = get_subcategory(subcategory_id)
    if "name" in fields:
        fields["name"] = _clean_name(
            subcategory.category_id, str(fields["name"]), exclude_id=subcategory.pk
        )
    if not fields:
        return subcategory
    try:
        with transaction.atomic():
            return subcategory_repository.update(subcategory, **fields)
    except IntegrityError as exc:
        raise _name_taken(str(fields.get("name", subcategory.name))) from exc


def _clean_name(category_id: int, name: str, *, exclude_id: int | None = None) -> str:
    name = name.strip()
    if not name:
        raise DomainError(
            "El nombre de la subcategoría es obligatorio.",
            code="invalid_subcategory_name",
            status_code=422,
        )
    if subcategory_repository.exists_by_name(category_id, name, exclude_id=exclude_id):
        raise _name_taken(name)
    return name


def _name_taken(name: str) -> DomainError:
    return DomainError(
        "La categoría ya tiene una subcategoría con ese nombre.",
        code="subcategory_name_taken",
        status_code=409,
        meta={"name": name},
    )
