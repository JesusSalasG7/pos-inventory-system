"""Acceso a datos de ventas. Única capa de la app que usa el ORM."""

from collections.abc import Sequence
from datetime import datetime
from decimal import Decimal
from typing import Any

from django.db.models import Count, F, QuerySet, Sum

from apps.auth.models import User
from apps.cash_sessions.models import CashSession
from apps.sales.domain.dtos import LineTotal, PaymentInput
from apps.sales.models import Sale, SaleDetail, SalePayment


def create_sale(
    *,
    cash_session: CashSession,
    user: User,
    branch: str,
    exchange_rate_at_invoice: Decimal,
    total_usd: Decimal,
    total_ves: Decimal,
    customer_tax_id: str = "",
    customer_name: str = "",
) -> Sale:
    """Inserta la cabecera de la venta con la tasa y los totales congelados."""
    return Sale.objects.create(
        cash_session=cash_session,
        user=user,
        branch_id=branch,
        exchange_rate_at_invoice=exchange_rate_at_invoice,
        total_usd=total_usd,
        total_ves=total_ves,
        customer_tax_id=customer_tax_id,
        customer_name=customer_name,
    )


def bulk_create_details(sale: Sale, lines: Sequence[LineTotal]) -> list[SaleDetail]:
    """Inserta todas las líneas de la venta con un único `bulk_create`."""
    return SaleDetail.objects.bulk_create(
        [
            SaleDetail(
                sale=sale,
                product_id=line.product_id,
                quantity=line.quantity,
                unit_price_usd=line.unit_price_usd,
                unit_cost_usd=line.unit_cost_usd,
                subtotal_usd=line.subtotal_usd,
                subtotal_ves=line.subtotal_ves,
            )
            for line in lines
        ]
    )


def bulk_create_payments(sale: Sale, payments: Sequence[PaymentInput]) -> list[SalePayment]:
    """Inserta todos los pagos de la venta con un único `bulk_create`."""
    return SalePayment.objects.bulk_create(
        [
            SalePayment(
                sale=sale,
                method=payment.method,
                currency=payment.currency,
                amount=payment.amount,
                approval_reference=payment.approval_reference,
            )
            for payment in payments
        ]
    )


def get_by_id(sale_id: int) -> Sale | None:
    """Devuelve la venta con `details` y `payments` precargados, o None."""
    return Sale.objects.prefetch_related("details", "payments").filter(pk=sale_id).first()


def list_filtered(
    *,
    branch: str | None = None,
    cash_session_id: int | None = None,
    date_from: datetime | None = None,
    date_to: datetime | None = None,
) -> QuerySet[Sale]:
    """Lista ventas filtradas, de la más reciente a la más antigua."""
    return (
        _filtered(branch=branch, date_from=date_from, date_to=date_to, session_id=cash_session_id)
        .prefetch_related("details", "payments")
        .order_by("-created_at", "-id")
    )


def summarize(
    *, branch: str | None, date_from: datetime | None, date_to: datetime | None
) -> dict[str, Decimal | int]:
    """Agrega cantidad de ventas y totales USD/VES del periodo con `aggregate`."""
    totals = _filtered(branch=branch, date_from=date_from, date_to=date_to).aggregate(
        sales_count=Count("id"), total_usd=Sum("total_usd"), total_ves=Sum("total_ves")
    )
    return {
        "sales_count": totals["sales_count"],
        "total_usd": totals["total_usd"] or Decimal("0.00"),
        "total_ves": totals["total_ves"] or Decimal("0.00"),
    }


def totals_by_session(cash_session_id: int) -> dict[str, Decimal | int]:
    """Cantidad de ventas y totales USD/VES facturados en una caja."""
    totals = Sale.objects.filter(cash_session_id=cash_session_id).aggregate(
        sales_count=Count("id"), total_usd=Sum("total_usd"), total_ves=Sum("total_ves")
    )
    return {
        "sales_count": totals["sales_count"],
        "total_usd": totals["total_usd"] or Decimal("0.00"),
        "total_ves": totals["total_ves"] or Decimal("0.00"),
    }


def list_lines_by_session(cash_session_id: int) -> list[dict[str, Any]]:
    """Líneas vendidas en una caja, con el nombre del producto y la tasa de su venta."""
    return list(
        SaleDetail.objects.filter(sale__cash_session_id=cash_session_id)
        .order_by("id")
        .values(
            "product_id",
            "quantity",
            "subtotal_usd",
            "subtotal_ves",
            "unit_cost_usd",
            product_name=F("product__name"),
            rate=F("sale__exchange_rate_at_invoice"),
        )
    )


def payment_totals_by_session(cash_session_id: int) -> dict[tuple[str, str], Decimal]:
    """Suma los pagos de una caja agrupados por (método, moneda)."""
    rows = (
        SalePayment.objects.filter(sale__cash_session_id=cash_session_id)
        .values("method", "currency")
        .annotate(total=Sum("amount"))
    )
    return {(row["method"], row["currency"]): row["total"] for row in rows}


def _filtered(
    *,
    branch: str | None,
    date_from: datetime | None,
    date_to: datetime | None,
    session_id: int | None = None,
) -> QuerySet[Sale]:
    queryset = Sale.objects.all()
    if branch is not None:
        queryset = queryset.filter(branch_id=branch)
    if session_id is not None:
        queryset = queryset.filter(cash_session_id=session_id)
    if date_from is not None:
        queryset = queryset.filter(created_at__gte=date_from)
    if date_to is not None:
        queryset = queryset.filter(created_at__lte=date_to)
    return queryset
