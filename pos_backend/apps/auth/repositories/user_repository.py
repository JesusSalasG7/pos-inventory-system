"""Acceso a datos de usuarios."""

from django.db.models import QuerySet

from apps.auth.models import User
from core.enums import Role


def list_users(*, only_active: bool = False) -> QuerySet[User]:
    """Lista los usuarios ordenados por nombre de usuario."""
    queryset = User.objects.order_by("username", "id")
    if only_active:
        queryset = queryset.filter(is_active=True)
    return queryset


def get_by_id(user_id: int) -> User | None:
    """Devuelve el usuario o None si no existe."""
    return User.objects.filter(pk=user_id).first()


def exists_by_username(username: str) -> bool:
    """Indica si el nombre de usuario ya está en uso, sin distinguir mayúsculas."""
    return User.objects.filter(username__iexact=username).exists()


def create(
    *, username: str, password: str, full_name: str, role: Role, assigned_branch: str | None
) -> User:
    """Crea el usuario con `User.objects.create_user`, que cifra la contraseña."""
    return User.objects.create_user(
        username=username,
        password=password,
        full_name=full_name,
        role=role,
        assigned_branch_id=assigned_branch,
    )


def update(user: User, *, password: str | None = None, **fields: object) -> User:
    """Actualiza solo los campos indicados usando `update_fields`.

    Si se indica `password`, se guarda cifrada con `set_password`.
    """
    for field, value in fields.items():
        setattr(user, field, value)
    update_fields = [*fields, "updated_at"]
    if password is not None:
        user.set_password(password)
        update_fields.append("password")
    user.save(update_fields=update_fields)
    return user
