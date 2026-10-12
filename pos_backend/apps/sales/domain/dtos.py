"""DTOs inmutables de entrada y resultado para los services de ventas."""

from dataclasses import dataclass
from datetime import datetime
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
    # Cliente registrado. Obligatorio si un pago es `CREDIT`.
    customer_id: int | None = None
    # Plazo de la deuda en días; sin indicarlo vale el del cliente.
    credit_days: int | None = None


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
    # Abonos de deudas cobrados en la caja, por método. No son ventas del turno.
    credit_collections: tuple[PaymentTotal, ...] = ()


@dataclass(frozen=True)
class SalesAggregate:
    """Lo vendido en un conjunto de líneas: base de las estadísticas."""

    units: Decimal
    revenue_usd: Decimal
    cost_usd: Decimal
    # Ventas distintas a las que pertenecen las líneas.
    sales_count: int

    @property
    def profit_usd(self) -> Decimal:
        return self.revenue_usd - self.cost_usd


@dataclass(frozen=True)
class GroupSalesAggregate:
    """Lo vendido de una categoría o subcategoría. `id` nulo: productos sin subcategoría."""

    id: int | None
    name: str | None
    totals: SalesAggregate


@dataclass(frozen=True)
class ProductSalesAggregate:
    """Lo vendido de un producto, con su clasificación actual en el catálogo."""

    product_id: int
    product_name: str
    unit_of_measure: str
    category_id: int
    category_name: str
    subcategory_id: int | None
    subcategory_name: str | None
    totals: SalesAggregate


@dataclass(frozen=True)
class ProductSalesActivity:
    """Última venta de un producto y unidades vendidas desde una fecha."""

    last_sale_at: datetime
    recent_units: Decimal


@dataclass(frozen=True)
class CreditSplitAggregate:
    """Lo vendido en un período y la parte que se dejó a crédito.

    Una venta puede ser a crédito solo en parte: sus líneas se reparten en la
    proporción `deuda ÷ total de la venta`. Los importes van sin redondear.
    """

    revenue_usd: Decimal
    cost_usd: Decimal
    # Parte que quedó como deuda al vender.
    credit_revenue_usd: Decimal
    credit_cost_usd: Decimal
    # Parte que sigue sin cobrarse hoy.
    pending_revenue_usd: Decimal
    pending_cost_usd: Decimal
