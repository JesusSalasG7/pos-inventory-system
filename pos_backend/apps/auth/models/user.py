"""Usuario del sistema (gerentes y supervisores)."""

from __future__ import annotations

from typing import Any

from django.contrib.auth.models import AbstractBaseUser, BaseUserManager, PermissionsMixin
from django.db import models

from core.enums import Role
from core.models import TimeStampedModel


class UserManager(BaseUserManager["User"]):
    """Manager propio: el usuario se identifica por `username`."""

    use_in_migrations = True

    def create_user(self, username: str, password: str | None = None, **extra: Any) -> User:
        if not username:
            raise ValueError("El nombre de usuario es obligatorio.")
        user = self.model(username=username.strip(), **extra)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, username: str, password: str | None = None, **extra: Any) -> User:
        extra.setdefault("role", Role.MANAGER)
        # Sin sucursal asignada: acceso a todas.
        extra.setdefault("assigned_branch", None)
        extra.setdefault("is_staff", True)
        extra.setdefault("is_superuser", True)
        if not (extra["is_staff"] and extra["is_superuser"]):
            raise ValueError("Un superusuario requiere is_staff=True e is_superuser=True.")
        return self.create_user(username, password, **extra)


class User(AbstractBaseUser, PermissionsMixin, TimeStampedModel):
    username = models.CharField(max_length=150, unique=True)
    full_name = models.CharField(max_length=150)
    role = models.CharField(max_length=20, choices=Role.choices)
    # Vacío significa acceso a todas las sucursales; solo se admite en un MANAGER.
    assigned_branch = models.ForeignKey(
        "branches.Branch",
        to_field="code",
        db_column="assigned_branch",
        on_delete=models.PROTECT,
        related_name="users",
        null=True,
        blank=True,
    )
    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)

    objects = UserManager()

    USERNAME_FIELD = "username"
    REQUIRED_FIELDS = ["full_name"]

    class Meta:
        ordering = ["username"]

    def __str__(self) -> str:
        return self.username
