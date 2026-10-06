"""Reglas de negocio de las sucursales.

Las sucursales son datos, no código: cada instalación registra las suyas,
sea una sola o varias. El resto de apps las referencia por su `code`.
"""

import re

from django.db import IntegrityError, transaction
from django.db.models import QuerySet

from apps.branches.models import Branch
from apps.branches.repositories import branch_repository
from core.exceptions import DomainError, NotFoundError

CODE_PATTERN = re.compile(r"^[A-Z][A-Z0-9_]{0,19}$")
EDITABLE_FIELDS = frozenset({"name", "active"})


def list_branches(*, only_active: bool = False) -> QuerySet[Branch]:
    """Lista las sucursales."""
    return branch_repository.list_branches(only_active=only_active)


def get_branch(code: str) -> Branch:
    """Devuelve la sucursal o lanza NotFoundError `branch_not_found` (404)."""
    branch = branch_repository.get_by_code(code)
    if branch is None:
        raise NotFoundError(
            "La sucursal no existe.", code="branch_not_found", meta={"branch": code}
        )
    return branch


def get_active_codes() -> list[str]:
    """Códigos de las sucursales activas. Lo consultan `core.branch_scope` e inventario."""
    return branch_repository.get_active_codes()


def require_active(code: str) -> str:
    """Devuelve `code` si es una sucursal activa; si no, DomainError `invalid_branch`."""
    allowed = get_active_codes()
    if code not in allowed:
        raise DomainError(
            "La sucursal indicada no existe o está inactiva.",
            code="invalid_branch",
            meta={"branch": code, "allowed": allowed},
        )
    return code


def create_branch(*, code: str, name: str) -> Branch:
    """Crea una sucursal.

    Pasos:
    1. Normalizar el código a mayúsculas y validar su formato y que no exista.
    2. Dentro de `transaction.atomic()`: crear la sucursal y sus filas de
       inventario en stock cero para todos los productos.
    """
    # Import local: inventory depende a su vez de este service.
    from apps.inventory.services import stock_service

    code = code.strip().upper()
    if not CODE_PATTERN.match(code):
        raise DomainError(
            "El código debe empezar por una letra y usar solo letras, números y guion bajo.",
            code="invalid_branch_code",
            status_code=422,
            meta={"code": code},
        )
    name = _clean_name(name)
    if branch_repository.exists_by_code(code):
        raise _code_taken(code)

    try:
        with transaction.atomic():
            branch = branch_repository.create(code=code, name=name)
            stock_service.initialize_branch(branch.code)
    except IntegrityError as exc:
        raise _code_taken(code) from exc
    return branch


def update_branch(code: str, **fields: object) -> Branch:
    """Actualiza el nombre o el estado de la sucursal. El código nunca cambia.

    Reglas:
    - No se puede desactivar una sucursal con cajas abiertas
      (`branch_has_open_sessions`, 409): antes deben cerrarse.
    - Al reactivarla se completan las filas de inventario de los productos
      creados mientras estuvo inactiva.
    - Las sucursales nunca se borran: se desactivan con `active`.
    """
    # Imports locales: ambas apps dependen a su vez de este service.
    from apps.cash_sessions.services import cash_session_service
    from apps.inventory.services import stock_service

    unknown = fields.keys() - EDITABLE_FIELDS
    if unknown:
        raise ValueError(f"Campos no editables: {sorted(unknown)}")

    branch = get_branch(code)
    if "name" in fields:
        fields["name"] = _clean_name(str(fields["name"]))
    deactivating = branch.active and fields.get("active") is False
    activating = not branch.active and fields.get("active") is True

    if deactivating and cash_session_service.has_open_sessions_in_branch(branch.code):
        raise DomainError(
            "La sucursal tiene cajas abiertas; deben cerrarse antes de desactivarla.",
            code="branch_has_open_sessions",
            status_code=409,
            meta={"branch": branch.code},
        )
    if not fields:
        return branch

    with transaction.atomic():
        branch = branch_repository.update(branch, **fields)
        if activating:
            stock_service.initialize_branch(branch.code)
    return branch


def _clean_name(name: str) -> str:
    name = name.strip()
    if not name:
        raise DomainError(
            "El nombre de la sucursal es obligatorio.",
            code="invalid_branch_name",
            status_code=422,
        )
    return name


def _code_taken(code: str) -> DomainError:
    return DomainError(
        "Ya existe una sucursal con ese código.",
        code="branch_code_taken",
        status_code=409,
        meta={"code": code},
    )
