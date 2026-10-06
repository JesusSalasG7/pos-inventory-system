"""Resolución de la sucursal sobre la que opera una petición.

Las sucursales se identifican en todo el sistema por su `code` (str).
"""

from __future__ import annotations

from typing import TYPE_CHECKING

from core.enums import Role
from core.exceptions import BranchAccessDeniedError, DomainError

if TYPE_CHECKING:
    from apps.auth.models import User


def has_all_branches_access(user: User) -> bool:
    """Solo un MANAGER sin sucursal asignada puede operar en todas."""
    return user.role == Role.MANAGER and user.assigned_branch_id is None


def can_access_branch(user: User, branch: str) -> bool:
    """Indica si el usuario puede operar en la sucursal indicada."""
    return has_all_branches_access(user) or user.assigned_branch_id == branch


def resolve_branch(user: User, requested_branch: str | None) -> str:
    """Devuelve el código de la sucursal efectiva para el usuario.

    - Sin `requested_branch`: se usa la sucursal asignada al usuario. Un MANAGER
      con acceso a todas debe indicarla (error `branch_required`), salvo que el
      negocio tenga una sola sucursal activa: entonces se usa esa.
    - Con `requested_branch`: se valida que sea una sucursal activa
      (`invalid_branch`) y que el usuario tenga acceso
      (BranchAccessDeniedError → 403).
    """
    # Import local: los services de las apps dependen a su vez de este módulo.
    from apps.branches.services import branch_service

    if requested_branch is None:
        if user.assigned_branch_id is not None:
            return branch_service.require_active(user.assigned_branch_id)
        if not has_all_branches_access(user):
            raise BranchAccessDeniedError(meta={"assigned_branch": None})
        active = branch_service.get_active_codes()
        if len(active) == 1:
            return active[0]
        if not active:
            raise DomainError(
                "Todavía no se ha registrado ninguna sucursal.",
                code="no_branches",
                status_code=409,
            )
        raise DomainError(
            "Debe indicar la sucursal.", code="branch_required", meta={"allowed": active}
        )

    branch_service.require_active(requested_branch)
    if not can_access_branch(user, requested_branch):
        raise BranchAccessDeniedError(
            meta={
                "requested_branch": requested_branch,
                "assigned_branch": user.assigned_branch_id,
            }
        )
    return requested_branch
