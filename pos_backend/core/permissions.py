"""Permisos de DRF basados en rol y sucursal."""

from typing import Any

from rest_framework.permissions import BasePermission
from rest_framework.request import Request
from rest_framework.views import APIView

from core.branch_scope import can_access_branch, resolve_branch
from core.enums import Role
from core.exceptions import BranchAccessDeniedError


def _has_role(request: Request, roles: tuple[str, ...]) -> bool:
    user = request.user
    return bool(user and user.is_authenticated and user.role in roles)


class IsManager(BasePermission):
    """Solo usuarios con rol MANAGER."""

    def has_permission(self, request: Request, view: APIView) -> bool:
        return _has_role(request, (Role.MANAGER,))


class IsSupervisorOrManager(BasePermission):
    """Usuarios con rol SUPERVISOR o MANAGER."""

    def has_permission(self, request: Request, view: APIView) -> bool:
        return _has_role(request, (Role.SUPERVISOR, Role.MANAGER))


class HasBranchAccess(BasePermission):
    """Restringe el acceso por sucursal.

    Un SUPERVISOR solo opera en su sucursal asignada; un MANAGER sin sucursal
    asignada accede a todas. La sucursal se toma del parámetro `branch` (query string o
    cuerpo). Si no viene, se deja pasar y el service la resuelve con
    `resolve_branch`.
    """

    def has_permission(self, request: Request, view: APIView) -> bool:
        if not (request.user and request.user.is_authenticated):
            return False
        requested = request.query_params.get("branch")
        if requested is None and isinstance(request.data, dict):
            requested = request.data.get("branch")
        if requested is None:
            return True
        # Lanza BranchAccessDeniedError (403) con el detalle para el cliente.
        resolve_branch(request.user, requested)
        return True

    def has_object_permission(self, request: Request, view: APIView, obj: Any) -> bool:
        branch = getattr(obj, "branch_id", None)
        if branch is None:
            return True
        if not can_access_branch(request.user, branch):
            raise BranchAccessDeniedError(meta={"requested_branch": branch})
        return True
