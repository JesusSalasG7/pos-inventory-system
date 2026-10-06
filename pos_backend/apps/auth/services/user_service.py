"""Reglas de negocio de la gestión de usuarios."""

from django.contrib.auth.password_validation import validate_password
from django.core.exceptions import ValidationError
from django.db import IntegrityError, transaction
from django.db.models import QuerySet

from apps.auth.models import User
from apps.auth.repositories import user_repository
from apps.branches.services import branch_service
from apps.cash_sessions.services import cash_session_service
from core.enums import Role
from core.exceptions import DomainError, NotFoundError

EDITABLE_FIELDS = frozenset({"full_name", "role", "assigned_branch", "is_active", "password"})


def list_users(*, only_active: bool = False) -> QuerySet[User]:
    """Lista los usuarios del sistema."""
    return user_repository.list_users(only_active=only_active)


def get_user(user_id: int) -> User:
    """Devuelve el usuario o lanza NotFoundError `user_not_found` (404)."""
    user = user_repository.get_by_id(user_id)
    if user is None:
        raise NotFoundError(
            "El usuario no existe.", code="user_not_found", meta={"user_id": user_id}
        )
    return user


def create_user(
    *, username: str, password: str, full_name: str, role: Role, assigned_branch: str | None
) -> User:
    """Crea un usuario.

    Pasos:
    1. Validar que el `username` no esté en uso (sin distinguir mayúsculas).
    2. Validar la contraseña con los validadores de Django.
    3. Validar la coherencia rol/sucursal: `assigned_branch` es el código de una
       sucursal activa, o None (todas) solo para un MANAGER.
    4. Crear el usuario con la contraseña cifrada.
    """
    username = username.strip()
    full_name = _clean_full_name(full_name)
    if not username:
        raise DomainError(
            "El nombre de usuario es obligatorio.", code="invalid_username", status_code=422
        )
    if user_repository.exists_by_username(username):
        raise _username_taken(username)
    _require_coherent_branch(role, assigned_branch)
    if assigned_branch is not None:
        branch_service.require_active(assigned_branch)
    _require_valid_password(password, User(username=username, full_name=full_name))

    try:
        # El savepoint cubre la carrera entre dos altas con el mismo username.
        with transaction.atomic():
            return user_repository.create(
                username=username,
                password=password,
                full_name=full_name,
                role=role,
                assigned_branch=assigned_branch,
            )
    except IntegrityError as exc:
        raise _username_taken(username) from exc


def update_user(user_id: int, acting_user: User, **fields: object) -> User:
    """Actualiza datos del usuario; con `password` le asigna una contraseña nueva.

    Reglas:
    - El rol y la sucursal resultantes deben ser coherentes (solo un MANAGER puede
      quedar sin sucursal asignada, es decir, con acceso a todas).
    - No se puede desactivar ni cambiar de sucursal a un usuario con una caja
      abierta (`user_has_open_session`, 409): antes debe cerrarla.
    - Nadie puede desactivarse ni quitarse el rol de MANAGER a sí mismo
      (`cannot_modify_own_access`, 409), para no dejar el sistema sin gerente
      por error.
    - Los usuarios nunca se borran: se desactivan con `is_active`.
    """
    unknown = fields.keys() - EDITABLE_FIELDS
    if unknown:
        raise ValueError(f"Campos no editables: {sorted(unknown)}")

    user = get_user(user_id)
    password = fields.pop("password", None)
    if "full_name" in fields:
        fields["full_name"] = _clean_full_name(str(fields["full_name"]))

    new_role = fields.get("role", user.role)
    new_branch = fields.get("assigned_branch", user.assigned_branch_id)
    branch_changes = new_branch != user.assigned_branch_id
    deactivating = user.is_active and fields.get("is_active") is False

    if user.pk == acting_user.pk and (deactivating or new_role != Role.MANAGER):
        raise DomainError(
            "No puede desactivarse ni quitarse el rol de gerente a sí mismo.",
            code="cannot_modify_own_access",
            status_code=409,
        )
    _require_coherent_branch(new_role, new_branch)
    if branch_changes and new_branch is not None:
        branch_service.require_active(str(new_branch))
    if (deactivating or branch_changes) and (cash_session_service.has_open_session(user)):
        raise DomainError(
            "El usuario tiene una caja abierta; debe cerrarla antes de este cambio.",
            code="user_has_open_session",
            status_code=409,
            meta={"user_id": user.pk},
        )
    if password is not None:
        _require_valid_password(str(password), user)

    if not fields and password is None:
        return user
    if "assigned_branch" in fields:
        fields["assigned_branch_id"] = fields.pop("assigned_branch")
    return user_repository.update(user, password=password, **fields)


def _clean_full_name(full_name: str) -> str:
    full_name = full_name.strip()
    if not full_name:
        raise DomainError(
            "El nombre completo es obligatorio.", code="invalid_full_name", status_code=422
        )
    return full_name


def _require_coherent_branch(role: object, assigned_branch: object) -> None:
    if assigned_branch is None and role != Role.MANAGER:
        raise DomainError(
            "Solo un gerente puede tener acceso a todas las sucursales.",
            code="invalid_branch_assignment",
            status_code=422,
            meta={"role": str(role), "assigned_branch": None},
        )


def _require_valid_password(password: str, user: User) -> None:
    try:
        validate_password(password, user=user)
    except ValidationError as exc:
        raise DomainError(
            "La contraseña no cumple los requisitos de seguridad.",
            code="invalid_password",
            status_code=422,
            meta={"errors": list(exc.messages)},
        ) from exc


def _username_taken(username: str) -> DomainError:
    return DomainError(
        "El nombre de usuario ya está en uso.",
        code="username_taken",
        status_code=409,
        meta={"username": username},
    )
