"""DTOs inmutables de entrada y resultado para los services de ventas."""

from dataclasses import dataclass
from decimal import Decimal

from core.enums import Currency, PaymentMethod


@dataclass(frozen=True)
class SaleItemInput:
    """Línea solicitada por el cliente. Nunca incluye precio: sale de la BD."""

    product_id: int
    quantity: Decimal


@dataclass(frozen=True)
class PaymentInput:
    method: PaymentMethod
    currency: Currency
    amount: Decimal
    approval_reference: str = ""


@dataclass(frozen=True)
class CreateSaleInput:
    """Venta solicitada. Sin `branch` se factura en la sucursal de la caja abierta."""

    items: tuple[SaleItemInput, ...]
    payments: tuple[PaymentInput, ...]
    branch: str | None = None
    customer_tax_id: str = ""
    customer_name: str = ""


@dataclass(frozen=True)
class PricedLine:
    """Línea con el precio unitario ya leído de la base de datos."""

    product_id: int
    quantity: Decimal
    unit_price_usd: Decimal


@dataclass(frozen=True)
class LineTotal:
    product_id: int
    quantity: Decimal
    unit_price_usd: Decimal
    subtotal_usd: Decimal


@dataclass(frozen=True)
class SaleTotals:
    lines: tuple[LineTotal, ...]
    total_usd: Decimal
    total_ves: Decimal
