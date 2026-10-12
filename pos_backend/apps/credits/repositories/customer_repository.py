"""Acceso a datos de los clientes."""

from datetime import date
from decimal import Decimal

from django.db.models import Count, DecimalField, Min, Q, QuerySet, Sum, Value
from django.db.models.functions import Coalesce

from apps.auth.models import User
from apps.credits.models import Customer

ZERO = Value(Decimal("0.00"), output_field=DecimalField(max_digits=14, decimal_places=2))


def with_balances(
    queryset: QuerySet[Customer], *, branch: str | None, today: date
) -> QuerySet[Customer]:
    """Anota a cada cliente lo que debe en la sucursal (o en todas, sin sucursal).

    - `balance_usd`: saldo pendiente.
    - `overdue_usd`: parte del saldo cuyo plazo ya venció.
    - `open_credits`: deudas con saldo.
    - `next_due_date`: vencimiento más próximo de las deudas con saldo.
    """
    pending = Q(credits__balance_usd__gt=0)
    if branch is not None:
        pending &= Q(credits__branch_id=branch)
    overdue = pending & Q(credits__due_date__lt=today)
    return queryset.annotate(
        balance_usd=Coalesce(Sum("credits__balance_usd", filter=pending), ZERO),
        overdue_usd=Coalesce(Sum("credits__balance_usd", filter=overdue), ZERO),
        open_credits=Count("credits", filter=pending),
        next_due_date=Min("credits__due_date", filter=pending),
    )


def list_customers(
    *,
    branch: str | None,
    today: date,
    search: str | None = None,
    only_active: bool = False,
    with_debt: bool = False,
) -> QuerySet[Customer]:
    """Lista clientes con sus saldos, ordenados por nombre."""
    queryset = Customer.objects.all()
    if only_active:
        queryset = queryset.filter(active=True)
    if search:
        queryset = queryset.filter(
            Q(name__icontains=search) | Q(tax_id__icontains=search) | Q(phone__icontains=search)
        )
    queryset = with_balances(queryset, branch=branch, today=today)
    if with_debt:
        queryset = queryset.filter(balance_usd__gt=0)
    return queryset.order_by("name", "id")


def get_with_balance(customer_id: int, *, branch: str | None, today: date) -> Customer | None:
    """Devuelve el cliente con sus saldos anotados, o None."""
    return with_balances(
        Customer.objects.filter(pk=customer_id), branch=branch, today=today
    ).first()


def get_by_id(customer_id: int) -> Customer | None:
    """Devuelve el cliente o None si no existe."""
    return Customer.objects.filter(pk=customer_id).first()


def exists_by_tax_id(tax_id: str, *, exclude_id: int | None = None) -> bool:
    """Indica si otro cliente ya tiene esa cédula o RIF, sin distinguir mayúsculas."""
    queryset = Customer.objects.filter(tax_id__iexact=tax_id)
    if exclude_id is not None:
        queryset = queryset.exclude(pk=exclude_id)
    return queryset.exists()


def create(*, name: str, tax_id: str, phone: str, credit_days: int, created_by: User) -> Customer:
    """Inserta un cliente activo."""
    return Customer.objects.create(
        name=name, tax_id=tax_id, phone=phone, credit_days=credit_days, created_by=created_by
    )


def update(customer: Customer, **fields: object) -> Customer:
    """Actualiza solo los campos indicados usando `update_fields`."""
    for field, value in fields.items():
        setattr(customer, field, value)
    customer.save(update_fields=[*fields, "updated_at"])
    return customer
