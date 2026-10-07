"""Orquestador de ventas."""

from collections.abc import Iterable
from datetime import datetime
from decimal import Decimal

from django.conf import settings
from django.db import transaction
from django.db.models import QuerySet

from apps.auth.models import User
from apps.cash_sessions.services import cash_session_service
from apps.exchange_rate.services import (
    bcv_rate_service,
    exchange_rate_service,
    pricing_settings_service,
)
from apps.inventory.services import product_service, stock_service
from apps.sales.domain.dtos import CreateSaleInput, PaymentInput, PricedLine, SaleItemInput
from apps.sales.models import Sale
from apps.sales.repositories import sale_repository
from apps.sales.services import sale_calculator
from core.branch_scope import can_access_branch, has_all_branches_access, resolve_branch
from core.enums import Currency, PaymentMethod
from core.exceptions import BranchAccessDeniedError, DomainError, NotFoundError
from core.money import quantize_money, quantize_quantity

# Moneda en la que se liquida cada método de pago.
METHOD_CURRENCY = {
    PaymentMethod.CASH_USD: Currency.USD,
    PaymentMethod.CASH_VES: Currency.VES,
    PaymentMethod.POS_CARD: Currency.VES,
    PaymentMethod.MOBILE_PAYMENT: Currency.VES,
}
# Métodos electrónicos: exigen la referencia de aprobación del banco o terminal.
REFERENCE_REQUIRED = frozenset({PaymentMethod.POS_CARD, PaymentMethod.MOBILE_PAYMENT})


def create_sale(data: CreateSaleInput, user: User) -> Sale:
    """Registra una venta completa de forma atómica.

    Flujo:

    1. Verificar que el usuario tiene una caja abierta en la sucursal
       (`cash_session_service.get_open_session`). Si no, NoOpenSessionError → 409.
       Sin sucursal explícita se factura en la de la caja abierta.
    2. Obtener la tasa activa (`exchange_rate_service.get_active_rate`) y
       congelarla en la venta como `exchange_rate_at_invoice`. Se congela
       también la del BCV (`bcv_rate_at_invoice`), con la que se valora el
       costo en bolívares; si no hay ninguna del BCV, vale la tasa activa.
    3. Cargar los productos activos solicitados (`product_service`). El precio
       SIEMPRE sale de la base de datos, nunca del cliente. Un producto
       inexistente o inactivo lanza InactiveProductError → 422.
    4. Calcular los totales USD/VES con `sale_calculator.calculate_totals` y
       validar que los pagos mixtos cuadren dentro de la tolerancia
       (`sale_calculator.validate_payments` con `settings.PAYMENT_TOLERANCE_USD`).
       Si no cuadran, PaymentMismatchError → 422.
    5. Dentro de `transaction.atomic()`:
       a. Bloquear la caja y confirmar que sigue abierta, para que no pueda
          cerrarse a mitad de la venta.
       b. Bloquear las filas de inventario con `select_for_update`, ordenadas
          por `product_id` para evitar interbloqueos entre ventas concurrentes
          (`stock_service.lock_and_validate_stock`), y validar el stock
          disponible. Si falta, InsufficientStockError → 422.
       c. Crear Sale, SaleDetail y SalePayment.
       d. Descontar el stock con expresiones `F()` y registrar un
          InventoryMovement de tipo SALE por producto
          (`stock_service.discount_for_sale`).

    Los pasos 1 a 4 se ejecutan fuera de la transacción para mantener los
    bloqueos de fila el menor tiempo posible. Las líneas que repiten un mismo
    producto se agrupan en una sola, sumando sus cantidades.
    """
    quantities = _aggregate_quantities(data.items)
    payments = _clean_payments(data.payments)

    requested_branch = resolve_branch(user, data.branch) if data.branch is not None else None
    session = cash_session_service.get_open_session(user, requested_branch)
    branch = session.branch_id
    if not can_access_branch(user, branch):
        raise BranchAccessDeniedError(
            meta={"requested_branch": branch, "assigned_branch": user.assigned_branch_id}
        )

    rate = exchange_rate_service.get_active_rate().usd_to_ves_rate
    bcv_rate = bcv_rate_service.get_cost_rate() or rate

    products = product_service.get_active_products(quantities)
    lines = [
        PricedLine(
            product_id,
            quantity,
            products[product_id].sale_price_usd,
            products[product_id].cost_price_usd,
        )
        for product_id, quantity in quantities.items()
    ]

    round_ves_up = pricing_settings_service.get_settings().round_ves_up
    totals = sale_calculator.calculate_totals(lines, rate, round_ves_up=round_ves_up)
    sale_calculator.validate_payments(
        totals.total_usd,
        payments,
        sale_calculator.payment_rate(totals, rate),
        settings.PAYMENT_TOLERANCE_USD,
    )

    with transaction.atomic():
        session = cash_session_service.get_open_session(user, branch, lock=True)
        locked_inventory = stock_service.lock_and_validate_stock(branch, quantities)
        sale = sale_repository.create_sale(
            cash_session=session,
            user=user,
            branch=branch,
            exchange_rate_at_invoice=rate,
            bcv_rate_at_invoice=bcv_rate,
            total_usd=totals.total_usd,
            total_ves=totals.total_ves,
            customer_tax_id=data.customer_tax_id.strip(),
            customer_name=data.customer_name.strip(),
        )
        sale_repository.bulk_create_details(sale, totals.lines)
        sale_repository.bulk_create_payments(sale, payments)
        stock_service.discount_for_sale(
            sale=sale, locked_inventory=locked_inventory, quantities=quantities, user=user
        )

    return sale_repository.get_by_id(sale.pk)


def get_sale(sale_id: int, user: User) -> Sale:
    """Devuelve la venta con sus líneas y pagos.

    Valida que el usuario tenga acceso a la sucursal de la venta
    (BranchAccessDeniedError → 403).
    """
    sale = sale_repository.get_by_id(sale_id)
    if sale is None:
        raise NotFoundError("La venta no existe.", code="sale_not_found", meta={"sale_id": sale_id})
    if not can_access_branch(user, sale.branch_id):
        raise BranchAccessDeniedError(
            meta={"requested_branch": sale.branch_id, "assigned_branch": user.assigned_branch_id}
        )
    return sale


def list_sales(
    user: User,
    *,
    branch: str | None = None,
    cash_session_id: int | None = None,
    date_from: datetime | None = None,
    date_to: datetime | None = None,
) -> QuerySet[Sale]:
    """Lista ventas de la sucursal resuelta con `resolve_branch`.

    Un MANAGER con acceso a todas las sucursales que no indica ninguna recibe
    las ventas de todas.
    """
    return sale_repository.list_filtered(
        branch=_scope_branch(user, branch),
        cash_session_id=cash_session_id,
        date_from=date_from,
        date_to=date_to,
    )


def get_sales_summary(
    user: User,
    *,
    branch: str | None = None,
    date_from: datetime | None = None,
    date_to: datetime | None = None,
) -> dict[str, Decimal | int]:
    """Resumen del periodo: número de ventas y totales en USD y VES."""
    return sale_repository.summarize(
        branch=_scope_branch(user, branch), date_from=date_from, date_to=date_to
    )


def get_payment_totals_for_session(cash_session_id: int) -> dict[tuple[str, str], Decimal]:
    """Totales cobrados en una caja por (método, moneda).

    Lo consume `cash_count_service` para el arqueo: es el punto de entrada
    de otras apps a los datos de ventas.
    """
    return sale_repository.payment_totals_by_session(cash_session_id)


def _scope_branch(user: User, branch: str | None) -> str | None:
    if branch is None and has_all_branches_access(user):
        return None
    return resolve_branch(user, branch)


def _aggregate_quantities(items: Iterable[SaleItemInput]) -> dict[int, Decimal]:
    """Suma las cantidades por producto, conservando el orden de aparición."""
    quantities: dict[int, Decimal] = {}
    for item in items:
        quantity = quantize_quantity(item.quantity)
        if quantity <= 0:
            raise DomainError(
                "La cantidad de cada línea debe ser mayor que cero.",
                code="invalid_quantity",
                status_code=422,
                meta={"product_id": item.product_id, "quantity": str(item.quantity)},
            )
        quantities[item.product_id] = quantities.get(item.product_id, Decimal("0")) + quantity
    if not quantities:
        raise DomainError(
            "La venta debe tener al menos una línea.", code="empty_sale", status_code=422
        )
    return quantities


def _clean_payments(payments: Iterable[PaymentInput]) -> tuple[PaymentInput, ...]:
    """Normaliza los pagos y valida las reglas propias de cada método."""
    cleaned = []
    for index, payment in enumerate(payments):
        amount = quantize_money(payment.amount)
        reference = payment.approval_reference.strip()
        if amount <= 0:
            raise _invalid_payment("El monto de cada pago debe ser mayor que cero.", index)
        if METHOD_CURRENCY[PaymentMethod(payment.method)] != payment.currency:
            raise _invalid_payment(
                "La moneda no corresponde al método de pago.",
                index,
                method=str(payment.method),
                currency=str(payment.currency),
            )
        if payment.method in REFERENCE_REQUIRED and not reference:
            raise _invalid_payment(
                "Este método de pago requiere la referencia de aprobación.",
                index,
                method=str(payment.method),
            )
        cleaned.append(
            PaymentInput(
                method=PaymentMethod(payment.method),
                currency=Currency(payment.currency),
                amount=amount,
                approval_reference=reference,
            )
        )
    if not cleaned:
        raise _invalid_payment("La venta debe tener al menos un pago.", None)
    return tuple(cleaned)


def _invalid_payment(detail: str, index: int | None, **meta: str) -> DomainError:
    return DomainError(
        detail, code="invalid_payment", status_code=422, meta={"payment_index": index, **meta}
    )
