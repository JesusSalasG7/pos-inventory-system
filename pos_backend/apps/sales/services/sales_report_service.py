"""Resumen de lo vendido en una caja: totales, cobros, costo y ganancia."""

from decimal import Decimal

from apps.sales.domain.dtos import PaymentTotal, ProductSales, SessionSalesReport
from apps.sales.repositories import sale_repository
from core.enums import PaymentMethod
from core.money import quantize_money, usd_to_ves

ZERO = Decimal("0.00")
METHOD_ORDER = {method: index for index, method in enumerate(PaymentMethod.values)}


def build_session_report(cash_session_id: int) -> SessionSalesReport:
    """Arma el resumen de ventas de una caja, abierta o cerrada.

    - Los totales salen de las cabeceras de las ventas: son lo facturado.
    - El costo ("inversión") de cada línea es cantidad × costo unitario
      congelado en la venta, redondeado a 2 decimales.
    - Los bolívares vendidos de cada línea son los que se facturaron
      (`subtotal_ves`); los del costo se obtienen siempre con la tasa del BCV
      congelada en su venta (`bcv_rate_at_invoice`), nunca con la tasa manual
      con la que se cobró ni con la de hoy.
    - Ganancia = total facturado − costo, en cada moneda.

    El acceso del usuario a la caja lo valida quien llama
    (`cash_session_service.get_session`).
    """
    totals = sale_repository.totals_by_session(cash_session_id)

    by_product: dict[int, dict[str, Decimal | str]] = {}
    for line in sale_repository.list_lines_by_session(cash_session_id):
        cost_usd = quantize_money(line["quantity"] * line["unit_cost_usd"])
        row = by_product.setdefault(
            line["product_id"],
            {
                "product_name": line["product_name"],
                "quantity": Decimal("0.000"),
                "sales_usd": ZERO,
                "sales_ves": ZERO,
                "cost_usd": ZERO,
                "cost_ves": ZERO,
            },
        )
        row["quantity"] += line["quantity"]
        row["sales_usd"] += line["subtotal_usd"]
        row["sales_ves"] += line["subtotal_ves"]
        row["cost_usd"] += cost_usd
        row["cost_ves"] += usd_to_ves(cost_usd, line["cost_rate"])

    products = tuple(
        ProductSales(
            product_id=product_id,
            product_name=str(row["product_name"]),
            quantity=row["quantity"],
            sales_usd=row["sales_usd"],
            sales_ves=row["sales_ves"],
            cost_usd=row["cost_usd"],
            cost_ves=row["cost_ves"],
            profit_usd=row["sales_usd"] - row["cost_usd"],
            profit_ves=row["sales_ves"] - row["cost_ves"],
        )
        # Primero lo que más vendió.
        for product_id, row in sorted(
            by_product.items(), key=lambda entry: (-entry[1]["sales_usd"], entry[1]["product_name"])
        )
    )
    cost_usd = sum((product.cost_usd for product in products), ZERO)
    cost_ves = sum((product.cost_ves for product in products), ZERO)

    payments = tuple(
        PaymentTotal(method=method, currency=currency, amount=amount)
        for (method, currency), amount in sorted(
            sale_repository.payment_totals_by_session(cash_session_id).items(),
            key=lambda entry: METHOD_ORDER.get(entry[0][0], len(METHOD_ORDER)),
        )
    )

    return SessionSalesReport(
        sales_count=int(totals["sales_count"]),
        total_usd=totals["total_usd"],
        total_ves=totals["total_ves"],
        cost_usd=cost_usd,
        cost_ves=cost_ves,
        profit_usd=totals["total_usd"] - cost_usd,
        profit_ves=totals["total_ves"] - cost_ves,
        payments=payments,
        products=products,
    )
