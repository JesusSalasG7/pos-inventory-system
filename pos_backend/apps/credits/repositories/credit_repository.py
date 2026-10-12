"""Acceso a datos de las deudas y los abonos. Única capa de la app que usa el ORM."""

from collections.abc import Sequence
from datetime import date, datetime
from decimal import Decimal

from django.db.models import F, QuerySet, Sum

from apps.auth.models import User
from apps.cash_sessions.models import CashSession
from apps.credits.models import Credit, CreditPayment, CreditPaymentAllocation


def create_credit(
    *, sale_id: int, customer_id: int, branch: str, amount_usd: Decimal, due_date: date
) -> Credit:
    """Inserta la deuda de una venta a crédito, con todo el monto pendiente."""
    return Credit.objects.create(
        sale_id=sale_id,
        customer_id=customer_id,
        branch_id=branch,
        amount_usd=amount_usd,
        balance_usd=amount_usd,
        due_date=due_date,
    )


def list_credits(
    *,
    branch: str | None,
    customer_id: int | None = None,
    only_pending: bool = False,
    only_paid: bool = False,
    due_before: date | None = None,
) -> QuerySet[Credit]:
    """Lista deudas con el cliente precargado, de la que vence antes a la que vence después."""
    queryset = Credit.objects.select_related("customer")
    if branch is not None:
        queryset = queryset.filter(branch_id=branch)
    if customer_id is not None:
        queryset = queryset.filter(customer_id=customer_id)
    if only_pending:
        queryset = queryset.filter(balance_usd__gt=0)
    if only_paid:
        queryset = queryset.filter(balance_usd=0)
    if due_before is not None:
        queryset = queryset.filter(due_date__lt=due_before)
    return queryset.order_by("due_date", "id")


def lock_pending_by_customer(customer_id: int, branch: str) -> list[Credit]:
    """Bloquea las deudas con saldo del cliente en la sucursal, la más antigua primero.

    Debe llamarse dentro de `transaction.atomic()`. El orden fijo (vencimiento,
    id) evita interbloqueos entre dos abonos simultáneos del mismo cliente.
    """
    return list(
        Credit.objects.select_for_update()
        .filter(customer_id=customer_id, branch_id=branch, balance_usd__gt=0)
        .order_by("due_date", "id")
    )


def apply_payment(credit: Credit, amount_usd: Decimal, *, paid_at: datetime | None) -> None:
    """Descuenta el abono del saldo con `F()`; `paid_at` marca la deuda como saldada."""
    Credit.objects.filter(pk=credit.pk).update(
        balance_usd=F("balance_usd") - amount_usd, paid_at=paid_at
    )


def create_payment(
    *,
    customer_id: int,
    cash_session: CashSession,
    user: User,
    method: str,
    currency: str,
    amount: Decimal,
    approval_reference: str,
    usd_to_ves_rate: Decimal,
    amount_usd: Decimal,
) -> CreditPayment:
    """Inserta un abono en la caja indicada."""
    return CreditPayment.objects.create(
        customer_id=customer_id,
        cash_session=cash_session,
        user=user,
        branch_id=cash_session.branch_id,
        method=method,
        currency=currency,
        amount=amount,
        approval_reference=approval_reference,
        usd_to_ves_rate=usd_to_ves_rate,
        amount_usd=amount_usd,
    )


def bulk_create_allocations(
    payment: CreditPayment, allocations: Sequence[tuple[int, Decimal]]
) -> list[CreditPaymentAllocation]:
    """Inserta en qué deudas se repartió el abono: pares (credit_id, amount_usd)."""
    return CreditPaymentAllocation.objects.bulk_create(
        [
            CreditPaymentAllocation(payment=payment, credit_id=credit_id, amount_usd=amount)
            for credit_id, amount in allocations
        ]
    )


def get_payment(payment_id: int) -> CreditPayment | None:
    """Devuelve el abono con sus repartos precargados, o None."""
    return CreditPayment.objects.prefetch_related("allocations").filter(pk=payment_id).first()


def list_payments(*, customer_id: int, branch: str | None) -> QuerySet[CreditPayment]:
    """Abonos del cliente, del más reciente al más antiguo."""
    queryset = CreditPayment.objects.filter(customer_id=customer_id).prefetch_related("allocations")
    if branch is not None:
        queryset = queryset.filter(branch_id=branch)
    return queryset.order_by("-created_at", "-id")


def payment_totals_by_session(cash_session_id: int) -> dict[tuple[str, str], Decimal]:
    """Suma los abonos cobrados en una caja agrupados por (método, moneda)."""
    rows = (
        CreditPayment.objects.filter(cash_session_id=cash_session_id)
        .values("method", "currency")
        .annotate(total=Sum("amount"))
    )
    return {(row["method"], row["currency"]): row["total"] for row in rows}
