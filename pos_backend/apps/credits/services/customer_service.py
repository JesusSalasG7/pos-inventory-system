"""Reglas de negocio de los clientes a crédito."""

from django.db import IntegrityError, transaction
from django.db.models import QuerySet
from django.utils import timezone

from apps.auth.models import User
from apps.credits.models import Customer
from apps.credits.repositories import customer_repository
from core.branch_scope import has_all_branches_access, resolve_branch
from core.exceptions import DomainError, NotFoundError

EDITABLE_FIELDS = frozenset({"name", "tax_id", "phone", "credit_days", "active"})
MAX_CREDIT_DAYS = 365


def list_customers(
    user: User,
    *,
    branch: str | None = None,
    search: str | None = None,
    only_active: bool = False,
    with_debt: bool = False,
) -> QuerySet[Customer]:
    """Lista clientes con lo que deben en la sucursal resuelta con `resolve_branch`.

    Los clientes son de todo el negocio; las deudas, de cada sucursal. Un
    MANAGER con acceso a todas que no indica ninguna ve la deuda total.
    """
    return customer_repository.list_customers(
        branch=scope_branch(user, branch),
        today=timezone.localdate(),
        search=(search or "").strip() or None,
        only_active=only_active,
        with_debt=with_debt,
    )


def get_customer(customer_id: int, user: User, *, branch: str | None = None) -> Customer:
    """Devuelve el cliente con sus saldos o lanza `customer_not_found` (404)."""
    customer = customer_repository.get_with_balance(
        customer_id, branch=scope_branch(user, branch), today=timezone.localdate()
    )
    if customer is None:
        raise _not_found(customer_id)
    return customer


def require_active(customer_id: int) -> Customer:
    """Devuelve el cliente si se le puede vender a crédito.

    Lanza `customer_not_found` (404) si no existe e `inactive_customer` (422)
    si está desactivado. Lo usa `sale_service` al vender a crédito.
    """
    customer = customer_repository.get_by_id(customer_id)
    if customer is None:
        raise _not_found(customer_id)
    if not customer.active:
        raise DomainError(
            "El cliente está inactivo.",
            code="inactive_customer",
            status_code=422,
            meta={"customer_id": customer_id},
        )
    return customer


def create_customer(
    *, user: User, name: str, tax_id: str = "", phone: str = "", credit_days: int = 7
) -> Customer:
    """Crea un cliente activo. La cédula o RIF, si se indica, no se repite."""
    name = _clean_name(name)
    tax_id = _clean_tax_id(tax_id)
    validate_credit_days(credit_days)
    try:
        with transaction.atomic():
            customer = customer_repository.create(
                name=name,
                tax_id=tax_id,
                phone=phone.strip(),
                credit_days=credit_days,
                created_by=user,
            )
    except IntegrityError as exc:
        raise _tax_id_taken(tax_id) from exc
    return get_customer(customer.pk, user)


def update_customer(customer_id: int, user: User, **fields: object) -> Customer:
    """Cambia los datos del cliente. Nunca se borra: se desactiva con `active`.

    Un cliente inactivo conserva sus deudas y puede seguir abonando, pero no
    se le vende más a crédito.
    """
    unknown = fields.keys() - EDITABLE_FIELDS
    if unknown:
        raise ValueError(f"Campos no editables: {sorted(unknown)}")

    customer = customer_repository.get_by_id(customer_id)
    if customer is None:
        raise _not_found(customer_id)
    if "name" in fields:
        fields["name"] = _clean_name(str(fields["name"]))
    if "tax_id" in fields:
        fields["tax_id"] = _clean_tax_id(str(fields["tax_id"]), exclude_id=customer.pk)
    if "phone" in fields:
        fields["phone"] = str(fields["phone"]).strip()
    if "credit_days" in fields:
        validate_credit_days(int(fields["credit_days"]))
    if fields:
        try:
            with transaction.atomic():
                customer_repository.update(customer, **fields)
        except IntegrityError as exc:
            raise _tax_id_taken(str(fields.get("tax_id", customer.tax_id))) from exc
    return get_customer(customer.pk, user)


def validate_credit_days(days: int) -> None:
    """El plazo de un crédito va de 0 (vence hoy) a `MAX_CREDIT_DAYS` días."""
    if not 0 <= days <= MAX_CREDIT_DAYS:
        raise DomainError(
            f"El plazo debe estar entre 0 y {MAX_CREDIT_DAYS} días.",
            code="invalid_credit_days",
            status_code=422,
            meta={"credit_days": days, "max_credit_days": MAX_CREDIT_DAYS},
        )


def scope_branch(user: User, branch: str | None) -> str | None:
    """Sucursal de la consulta; None para un MANAGER con acceso a todas que no indica ninguna."""
    if branch is None and has_all_branches_access(user):
        return None
    return resolve_branch(user, branch)


def _clean_name(name: str) -> str:
    name = name.strip()
    if not name:
        raise DomainError(
            "El nombre del cliente es obligatorio.",
            code="invalid_customer_name",
            status_code=422,
        )
    return name


def _clean_tax_id(tax_id: str, *, exclude_id: int | None = None) -> str:
    tax_id = tax_id.strip().upper()
    if tax_id and customer_repository.exists_by_tax_id(tax_id, exclude_id=exclude_id):
        raise _tax_id_taken(tax_id)
    return tax_id


def _tax_id_taken(tax_id: str) -> DomainError:
    return DomainError(
        "Ya existe un cliente con esa cédula o RIF.",
        code="customer_tax_id_taken",
        status_code=409,
        meta={"tax_id": tax_id},
    )


def _not_found(customer_id: int) -> NotFoundError:
    return NotFoundError(
        "El cliente no existe.", code="customer_not_found", meta={"customer_id": customer_id}
    )
