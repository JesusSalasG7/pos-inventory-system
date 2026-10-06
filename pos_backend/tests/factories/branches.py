from typing import Any

import factory

from apps.branches.models import Branch

# Los tests de integración trabajan con dos sucursales (ver tests/integration/conftest.py).
VILLA_LIBERTAD = "VILLA_LIBERTAD"
LAS_AMERICAS = "LAS_AMERICAS"


class BranchFactory(factory.django.DjangoModelFactory):
    class Meta:
        model = Branch
        django_get_or_create = ("code",)

    code = VILLA_LIBERTAD
    name = factory.LazyAttribute(lambda branch: branch.code.replace("_", " ").title())


class BranchCodeMixin:
    """Permite pasar la sucursal a una factory por su código, además de por instancia."""

    _branch_fields: tuple[str, ...] = ("branch",)

    @classmethod
    def _adjust_kwargs(cls, **kwargs: Any) -> dict[str, Any]:
        for field in cls._branch_fields:
            if isinstance(kwargs.get(field), str):
                kwargs[field] = BranchFactory(code=kwargs[field])
        return kwargs
