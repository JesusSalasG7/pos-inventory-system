"""Acceso a datos de las subcategorías del catálogo."""

from django.db.models import QuerySet

from apps.inventory.models import Subcategory


def list_subcategories(
    *, only_active: bool = False, category_id: int | None = None
) -> QuerySet[Subcategory]:
    """Lista las subcategorías ordenadas por nombre."""
    queryset = Subcategory.objects.order_by("name", "id")
    if only_active:
        queryset = queryset.filter(active=True)
    if category_id is not None:
        queryset = queryset.filter(category_id=category_id)
    return queryset


def get_by_id(subcategory_id: int) -> Subcategory | None:
    """Devuelve la subcategoría o None si no existe."""
    return Subcategory.objects.filter(pk=subcategory_id).first()


def exists_by_name(category_id: int, name: str, *, exclude_id: int | None = None) -> bool:
    """Indica si la categoría ya tiene una subcategoría con ese nombre.

    No distingue mayúsculas.
    """
    queryset = Subcategory.objects.filter(category_id=category_id, name__iexact=name)
    if exclude_id is not None:
        queryset = queryset.exclude(pk=exclude_id)
    return queryset.exists()


def create(*, category_id: int, name: str) -> Subcategory:
    """Inserta una subcategoría activa."""
    return Subcategory.objects.create(category_id=category_id, name=name)


def update(subcategory: Subcategory, **fields: object) -> Subcategory:
    """Actualiza solo los campos indicados usando `update_fields`."""
    for field, value in fields.items():
        setattr(subcategory, field, value)
    subcategory.save(update_fields=[*fields, "updated_at"])
    return subcategory
