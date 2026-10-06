from datetime import datetime
from decimal import Decimal
from unittest.mock import patch

import pytest
from django.core.cache import cache
from rest_framework.test import APIClient

from apps.auth.models import User
from apps.exchange_rate.domain.dtos import BcvRate
from apps.exchange_rate.models import ExchangeRate
from apps.exchange_rate.services import bcv_rate_service

pytestmark = pytest.mark.django_db

BCV_URL = "/api/v1/exchange-rates/bcv/"
BCV_RATE = BcvRate(
    rate=Decimal("872.3927"), updated_at=datetime.fromisoformat("2026-10-06T00:00:00-04:00")
)


@pytest.fixture(autouse=True)
def clean_cache() -> None:
    cache.clear()
    yield
    cache.clear()


def _patch_fetch(**kwargs: object):
    return patch.object(bcv_rate_service, "_fetch_bcv_rate", **kwargs)


def test_bcv_rate_requires_authentication(api_client: APIClient) -> None:
    assert api_client.get(BCV_URL).status_code == 401


def test_supervisor_gets_bcv_rate(api_client: APIClient, supervisor: User) -> None:
    api_client.force_authenticate(supervisor)

    with _patch_fetch(return_value=BCV_RATE):
        response = api_client.get(BCV_URL)

    assert response.status_code == 200
    assert response.data == {
        "rate": "872.3927",
        "updated_at": "2026-10-06T00:00:00-04:00",
    }
    # Es solo una referencia: no registra ninguna tasa.
    assert ExchangeRate.objects.count() == 0


def test_bcv_rate_unavailable_returns_503(api_client: APIClient, manager: User) -> None:
    api_client.force_authenticate(manager)

    with _patch_fetch(side_effect=ValueError("respuesta inesperada")):
        response = api_client.get(BCV_URL)

    assert response.status_code == 503
    assert response.data["code"] == "bcv_rate_unavailable"
