import pytest
from rest_framework.test import APIClient

from apps.auth.models import User
from core.enums import Role
from tests.factories import UserFactory


@pytest.fixture
def api_client() -> APIClient:
    return APIClient()


@pytest.fixture
def supervisor(db: None) -> User:
    """Supervisor asignado a VILLA_LIBERTAD."""
    return UserFactory()


@pytest.fixture
def manager(db: None) -> User:
    """Gerente con acceso a todas las sucursales."""
    return UserFactory(role=Role.MANAGER, assigned_branch=None)
