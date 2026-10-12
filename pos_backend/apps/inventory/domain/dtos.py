"""DTOs inmutables de resultado para los services de inventario."""

from dataclasses import dataclass
from decimal import Decimal


@dataclass(frozen=True)
class ProductStock:
    """Existencias de un producto en una sucursal, con su costo actual."""

    product_id: int
    product_name: str
    unit_of_measure: str
    active: bool
    current_stock: Decimal
    cost_price_usd: Decimal
