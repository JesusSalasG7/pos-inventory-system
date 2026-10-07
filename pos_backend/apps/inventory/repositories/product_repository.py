"""Acceso a datos del catálogo de productos."""

from collections.abc import Iterable
from decimal import Decimal

from django.db.models import QuerySet

from apps.inventory.models import Product
from core.enums import UnitOfMeasure


def list_products(
    *, only_active: bool = False, category_id: int | None = None, search: str | None = None
) -> QuerySet[Product]:
    """Lista el catálogo con filtros opcionales, ordenado por nombre."""
    queryset = Product.objects.select_related("category").order_by("name", "id")
    if only_active:
        queryset = queryset.filter(active=True)
    if category_id is not None:
        queryset = queryset.filter(category_id=category_id)
    if search:
        queryset = queryset.filter(name__icontains=search)
    return queryset


def get_by_id(product_id: int) -> Product | None:
    """Devuelve el producto o None si no existe."""
    return Product.objects.select_related("category").filter(pk=product_id).first()


def get_active_by_ids(product_ids: Iterable[int]) -> dict[int, Product]:
    """Devuelve los productos activos indexados por id, en una sola consulta."""
    return Product.objects.filter(active=True).in_bulk(list(product_ids))


def exists_by_name(name: str, *, exclude_id: int | None = None) -> bool:
    """Indica si ya hay un producto con ese nombre, sin distinguir mayúsculas."""
    queryset = Product.objects.filter(name__iexact=name)
    if exclude_id is not None:
        queryset = queryset.exclude(pk=exclude_id)
    return queryset.exists()


def create(
    *,
    name: str,
    category_id: int,
    unit_of_measure: UnitOfMeasure,
    cost_price_usd: Decimal,
    sale_price_usd: Decimal,
) -> Product:
    """Inserta un producto activo."""
    return Product.objects.create(
        name=name,
        category_id=category_id,
        unit_of_measure=unit_of_measure,
        cost_price_usd=cost_price_usd,
        sale_price_usd=sale_price_usd,
    )


def update(product: Product, **fields: object) -> Product:
    """Actualiza solo los campos indicados usando `update_fields`."""
    for field, value in fields.items():
        setattr(product, field, value)
    product.save(update_fields=[*fields, "updated_at"])
    return product


def set_active(product: Product, active: bool) -> Product:
    """Activa o desactiva el producto."""
    return update(product, active=active)
