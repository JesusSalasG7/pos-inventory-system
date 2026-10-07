from unittest.mock import patch

import pytest
import requests
from django.core.cache import cache

from apps.exchange_rate.services import bcv_rate_service
from tests.factories import LAS_AMERICAS, VILLA_LIBERTAD, BranchFactory


@pytest.fixture(autouse=True)
def branches(db: None) -> None:
    """Negocio con dos sucursales activas, el escenario por defecto de estos tests."""
    BranchFactory(code=VILLA_LIBERTAD)
    BranchFactory(code=LAS_AMERICAS)


@pytest.fixture(autouse=True)
def bcv_offline() -> None:
    """El BCV no responde salvo que el test lo simule: ningún test sale a la red."""
    cache.clear()
    with patch.object(
        bcv_rate_service, "_fetch_bcv_rate", side_effect=requests.ConnectionError("sin red")
    ):
        yield
    cache.clear()
