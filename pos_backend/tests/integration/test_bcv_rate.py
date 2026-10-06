from datetime import date, datetime
from decimal import Decimal
from unittest.mock import patch

import pytest
from django.core.cache import cache
from django.core.management import call_command
from django.core.management.base import CommandError
from rest_framework.test import APIClient

from apps.auth.models import User
from apps.exchange_rate.domain.dtos import BcvRate
from apps.exchange_rate.models import ExchangeRate
from apps.exchange_rate.services import bcv_rate_service, exchange_rate_service
from core.enums import RateSource
from core.exceptions import DomainError

pytestmark = pytest.mark.django_db

BCV_URL = "/api/v1/exchange-rates/bcv/"
RATES_URL = "/api/v1/exchange-rates/"
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


# --- Sincronización automática de la tasa activa con el BCV ---

SYNC_URL = "/api/v1/exchange-rates/bcv/sync/"
CURRENT_URL = "/api/v1/exchange-rates/current/"
NEXT_BCV_RATE = BcvRate(
    rate=Decimal("875.1000"), updated_at=datetime.fromisoformat("2026-10-07T00:00:00-04:00")
)


def test_sync_registers_bcv_rate_as_active() -> None:
    with _patch_fetch(return_value=BCV_RATE):
        created = bcv_rate_service.sync_active_rate()

    assert created is not None
    assert created.usd_to_ves_rate == Decimal("872.3927")
    assert created.source == RateSource.BCV
    assert created.effective_date == date(2026, 10, 6)
    assert created.created_by is None
    assert exchange_rate_service.get_active_rate() == created


def test_sync_does_nothing_while_bcv_does_not_change() -> None:
    with _patch_fetch(return_value=BCV_RATE):
        bcv_rate_service.sync_active_rate()
        assert bcv_rate_service.sync_active_rate() is None

    assert ExchangeRate.objects.count() == 1


def test_sync_registers_each_new_bcv_publication() -> None:
    with _patch_fetch(return_value=BCV_RATE):
        bcv_rate_service.sync_active_rate()
    with _patch_fetch(return_value=NEXT_BCV_RATE):
        created = bcv_rate_service.sync_active_rate()

    assert created.effective_date == date(2026, 10, 7)
    assert exchange_rate_service.get_active_rate().usd_to_ves_rate == Decimal("875.1000")
    assert ExchangeRate.objects.count() == 2


def test_same_rate_on_a_new_day_is_registered() -> None:
    same_rate_next_day = BcvRate(rate=BCV_RATE.rate, updated_at=NEXT_BCV_RATE.updated_at)
    with _patch_fetch(return_value=BCV_RATE):
        bcv_rate_service.sync_active_rate()
    with _patch_fetch(return_value=same_rate_next_day):
        created = bcv_rate_service.sync_active_rate()

    assert created is not None
    assert created.effective_date == date(2026, 10, 7)


def test_manual_rate_stays_active_until_bcv_publishes_a_new_one(manager: User) -> None:
    with _patch_fetch(return_value=BCV_RATE):
        bcv_rate_service.sync_active_rate()
    manual = exchange_rate_service.register_rate(usd_to_ves_rate=Decimal("900"), user=manager)
    assert manual.source == RateSource.MANUAL

    # El BCV no cambió: la tasa manual del gerente se respeta.
    with _patch_fetch(return_value=BCV_RATE):
        assert bcv_rate_service.sync_active_rate() is None
    assert exchange_rate_service.get_active_rate() == manual

    # El BCV publica una tasa nueva: reemplaza a la manual.
    with _patch_fetch(return_value=NEXT_BCV_RATE):
        bcv_rate_service.sync_active_rate()
    assert exchange_rate_service.get_active_rate().source == RateSource.BCV


def test_sync_registers_nothing_when_bcv_is_unavailable(manager: User) -> None:
    manual = exchange_rate_service.register_rate(usd_to_ves_rate=Decimal("900"), user=manager)

    with _patch_fetch(side_effect=ValueError("respuesta inesperada")):
        with pytest.raises(DomainError) as exc_info:
            bcv_rate_service.sync_active_rate()

    assert exc_info.value.code == "bcv_rate_unavailable"
    assert exc_info.value.status_code == 503
    assert exchange_rate_service.get_active_rate() == manual


def test_sync_command(capsys: pytest.CaptureFixture[str]) -> None:
    with _patch_fetch(return_value=BCV_RATE):
        call_command("sync_bcv_rate")
        output = capsys.readouterr().out
        assert "872.3927" in output
        assert "06/10/2026" in output
        call_command("sync_bcv_rate")
        assert "no cambió" in capsys.readouterr().out

    with _patch_fetch(side_effect=ValueError("x")), pytest.raises(CommandError):
        call_command("sync_bcv_rate")


def test_sync_endpoint(api_client: APIClient, manager: User, supervisor: User) -> None:
    api_client.force_authenticate(supervisor)
    assert api_client.post(SYNC_URL).status_code == 403

    api_client.force_authenticate(manager)
    with _patch_fetch(return_value=BCV_RATE):
        created = api_client.post(SYNC_URL)
        unchanged = api_client.post(SYNC_URL)

    assert created.status_code == 201
    assert created.data["source"] == "BCV"
    assert created.data["effective_date"] == "2026-10-06"
    assert created.data["created_by"] is None
    assert unchanged.status_code == 200
    assert unchanged.data["id"] == created.data["id"]

    current = api_client.get(CURRENT_URL)
    assert current.data["usd_to_ves_rate"] == "872.3927"

    with _patch_fetch(side_effect=ValueError("x")):
        failed = api_client.post(SYNC_URL)
    assert failed.status_code == 503
    assert failed.data["code"] == "bcv_rate_unavailable"


def test_manual_rate_reports_its_source(api_client: APIClient, manager: User) -> None:
    api_client.force_authenticate(manager)

    response = api_client.post(RATES_URL, {"usd_to_ves_rate": "900"}, format="json")

    assert response.status_code == 201
    assert response.data["source"] == "MANUAL"
    assert response.data["effective_date"] is None
    assert response.data["created_by"] == manager.pk
