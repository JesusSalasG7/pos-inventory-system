"""Acceso a datos de las sucursales."""

from django.db.models import QuerySet

from apps.branches.models import Branch


def list_branches(*, only_active: bool = False) -> QuerySet[Branch]:
    """Lista las sucursales ordenadas por nombre."""
    queryset = Branch.objects.order_by("name", "id")
    if only_active:
        queryset = queryset.filter(active=True)
    return queryset


def get_by_code(code: str) -> Branch | None:
    """Devuelve la sucursal o None si no existe."""
    return Branch.objects.filter(code=code).first()


def exists_by_code(code: str) -> bool:
    """Indica si el código ya está en uso."""
    return Branch.objects.filter(code=code).exists()


def get_active_codes() -> list[str]:
    """Devuelve los códigos de las sucursales activas, ordenados."""
    return list(Branch.objects.filter(active=True).order_by("code").values_list("code", flat=True))


def create(*, code: str, name: str) -> Branch:
    """Inserta una sucursal activa."""
    return Branch.objects.create(code=code, name=name)


def update(branch: Branch, **fields: object) -> Branch:
    """Actualiza solo los campos indicados usando `update_fields`."""
    for field, value in fields.items():
        setattr(branch, field, value)
    branch.save(update_fields=[*fields, "updated_at"])
    return branch
