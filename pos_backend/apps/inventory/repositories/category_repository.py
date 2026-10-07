"""Acceso a datos de las categorías del catálogo."""

from django.db.models import QuerySet

from apps.inventory.models import Category


def list_categories(*, only_active: bool = False) -> QuerySet[Category]:
    """Lista las categorías ordenadas por nombre."""
    queryset = Category.objects.order_by("name", "id")
    if only_active:
        queryset = queryset.filter(active=True)
    return queryset


def get_by_id(category_id: int) -> Category | None:
    """Devuelve la categoría o None si no existe."""
    return Category.objects.filter(pk=category_id).first()


def exists_by_name(name: str, *, exclude_id: int | None = None) -> bool:
    """Indica si ya hay una categoría con ese nombre, sin distinguir mayúsculas."""
    queryset = Category.objects.filter(name__iexact=name)
    if exclude_id is not None:
        queryset = queryset.exclude(pk=exclude_id)
    return queryset.exists()


def create(*, name: str, icon: str = "") -> Category:
    """Inserta una categoría activa."""
    return Category.objects.create(name=name, icon=icon)


def update(category: Category, **fields: object) -> Category:
    """Actualiza solo los campos indicados usando `update_fields`."""
    for field, value in fields.items():
        setattr(category, field, value)
    category.save(update_fields=[*fields, "updated_at"])
    return category
