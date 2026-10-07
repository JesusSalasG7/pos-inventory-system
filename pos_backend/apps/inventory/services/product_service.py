"""Reglas de negocio del catálogo de productos."""

from collections.abc import Iterable
from decimal import Decimal

from django.db import transaction
from django.db.models import QuerySet

from apps.branches.services import branch_service
from apps.inventory.models import Product
from apps.inventory.repositories import branch_inventory_repository, product_repository
from apps.inventory.services import category_service
from core.enums import UnitOfMeasure
from core.exceptions import DomainError, InactiveProductError, NotFoundError

EDITABLE_FIELDS = frozenset(
    {"name", "category_id", "unit_of_measure", "cost_price_usd", "sale_price_usd"}
)
PRICE_FIELDS = ("cost_price_usd", "sale_price_usd")


def list_products(
    *, only_active: bool = False, category_id: int | None = None, search: str | None = None
) -> QuerySet[Product]:
    """Lista el catálogo aplicando los filtros recibidos."""
    return product_repository.list_products(
        only_active=only_active, category_id=category_id, search=search
    )


def get_product(product_id: int) -> Product:
    """Devuelve el producto o lanza NotFoundError `product_not_found` (404)."""
    product = product_repository.get_by_id(product_id)
    if product is None:
        raise NotFoundError(
            "El producto no existe.", code="product_not_found", meta={"product_id": product_id}
        )
    return product


def get_active_products(product_ids: Iterable[int]) -> dict[int, Product]:
    """Devuelve los productos activos indexados por id.

    Si falta alguno de los ids solicitados (no existe o está inactivo) lanza
    InactiveProductError con los ids faltantes en `meta`.

    Es el punto de entrada de `sale_service` para obtener precios confiables.
    """
    requested = set(product_ids)
    products = product_repository.get_active_by_ids(requested)
    missing = sorted(requested - products.keys())
    if missing:
        raise InactiveProductError(meta={"product_ids": missing})
    return products


def create_product(
    *,
    name: str,
    category_id: int,
    unit_of_measure: UnitOfMeasure,
    cost_price_usd: Decimal,
    sale_price_usd: Decimal,
) -> Product:
    """Crea un producto.

    Pasos:
    1. Validar el nombre (no vacío y no repetido), que la categoría exista y
       esté activa, y que los precios no sean negativos.
    2. Dentro de `transaction.atomic()`: crear el producto y sus filas de
       BranchInventory en stock cero para cada sucursal activa.
    """
    name = _clean_name(name)
    category_service.require_active(category_id)
    _require_non_negative_prices(cost_price_usd=cost_price_usd, sale_price_usd=sale_price_usd)

    with transaction.atomic():
        product = product_repository.create(
            name=name,
            category_id=category_id,
            unit_of_measure=unit_of_measure,
            cost_price_usd=cost_price_usd,
            sale_price_usd=sale_price_usd,
        )
        branch_inventory_repository.create_for_branches(product, branch_service.get_active_codes())
    return product


def update_product(product_id: int, **fields: object) -> Product:
    """Actualiza datos del producto. Los cambios de precio no afectan ventas pasadas."""
    unknown = fields.keys() - EDITABLE_FIELDS
    if unknown:
        raise ValueError(f"Campos no editables: {sorted(unknown)}")

    product = get_product(product_id)
    if "name" in fields:
        fields["name"] = _clean_name(str(fields["name"]), exclude_id=product.pk)
    # Un producto puede conservar una categoría desactivada, pero no pasar a una.
    if "category_id" in fields and fields["category_id"] != product.category_id:
        category_service.require_active(int(fields["category_id"]))
    _require_non_negative_prices(**{f: fields[f] for f in PRICE_FIELDS if f in fields})
    if not fields:
        return product
    return product_repository.update(product, **fields)


def toggle_active(product_id: int) -> Product:
    """Invierte el estado activo/inactivo. Un producto inactivo no puede venderse."""
    product = get_product(product_id)
    return product_repository.set_active(product, not product.active)


def _clean_name(name: str, *, exclude_id: int | None = None) -> str:
    name = name.strip()
    if not name:
        raise DomainError(
            "El nombre del producto es obligatorio.", code="invalid_name", status_code=422
        )
    if product_repository.exists_by_name(name, exclude_id=exclude_id):
        raise DomainError(
            "Ya existe un producto con ese nombre.",
            code="product_name_taken",
            status_code=409,
            meta={"name": name},
        )
    return name


def _require_non_negative_prices(**prices: Decimal) -> None:
    for field, value in prices.items():
        if value < 0:
            raise DomainError(
                "El precio no puede ser negativo.",
                code="invalid_price",
                status_code=422,
                meta={"field": field, "value": str(value)},
            )
