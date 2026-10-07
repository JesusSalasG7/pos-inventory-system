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
    """Línea con el precio y el costo unitarios ya leídos de la base de datos."""

    product_id: int
    quantity: Decimal
    unit_price_usd: Decimal
    unit_cost_usd: Decimal = Decimal("0.00")


@dataclass(frozen=True)
class LineTotal:
    product_id: int
    quantity: Decimal
    unit_price_usd: Decimal
    subtotal_usd: Decimal
    unit_cost_usd: Decimal = Decimal("0.00")
    subtotal_ves: Decimal = Decimal("0.00")


@dataclass(frozen=True)
class SaleTotals:
    lines: tuple[LineTotal, ...]
    total_usd: Decimal
    total_ves: Decimal


@dataclass(frozen=True)
class PaymentTotal:
    """Total cobrado con un método de pago, en la moneda de ese método."""

    method: str
    currency: str
    amount: Decimal


@dataclass(frozen=True)
class ProductSales:
    """Lo vendido de un producto: cantidad, venta, costo y ganancia."""

    product_id: int
    product_name: str
    quantity: Decimal
    sales_usd: Decimal
    sales_ves: Decimal
    cost_usd: Decimal
    cost_ves: Decimal
    profit_usd: Decimal
    profit_ves: Decimal


@dataclass(frozen=True)
class SessionSalesReport:
    """Resumen de lo vendido en una caja: totales, cobros, costo y ganancia."""

    sales_count: int
    total_usd: Decimal
    total_ves: Decimal
    cost_usd: Decimal
    cost_ves: Decimal
    profit_usd: Decimal
    profit_ves: Decimal
    payments: tuple[PaymentTotal, ...]
    products: tuple[ProductSales, ...]
