from decimal import Decimal

import pytest
from rest_framework.test import APIClient

from apps.auth.models import User
from apps.exchange_rate.models import ExchangeRate
from apps.exchange_rate.services import exchange_rate_service
from core.exceptions import DomainError
from tests.factories import ExchangeRateFactory

pytestmark = pytest.mark.django_db

RATES_URL = "/api/v1/exchange-rates/"
CURRENT_URL = "/api/v1/exchange-rates/current/"


def test_get_active_rate_without_rates_fails() -> None:
    with pytest.raises(DomainError) as exc_info:
        exchange_rate_service.get_active_rate()

    assert exc_info.value.code == "exchange_rate_not_set"
    assert exc_info.value.status_code == 409


def test_active_rate_is_the_most_recent(manager: User) -> None:
    exchange_rate_service.register_rate(usd_to_ves_rate=Decimal("150"), user=manager)
    latest = exchange_rate_service.register_rate(usd_to_ves_rate=Decimal("152.5"), user=manager)

    assert exchange_rate_service.get_active_rate() == latest
    assert ExchangeRate.objects.count() == 2  # el histórico se conserva


def test_register_rate_rounds_to_four_decimals(manager: User) -> None:
    rate = exchange_rate_service.register_rate(usd_to_ves_rate=Decimal("150.123456"), user=manager)

    rate.refresh_from_db()
    assert rate.usd_to_ves_rate == Decimal("150.1235")
    assert rate.created_by == manager


@pytest.mark.parametrize("value", ["0", "-1", "0.00004"])
def test_register_rate_must_be_positive(manager: User, value: str) -> None:
    with pytest.raises(DomainError) as exc_info:
        exchange_rate_service.register_rate(usd_to_ves_rate=Decimal(value), user=manager)

    assert exc_info.value.code == "invalid_exchange_rate"
    assert not ExchangeRate.objects.exists()


def test_list_rates_newest_first() -> None:
    old = ExchangeRateFactory()
    new = ExchangeRateFactory()

    assert list(exchange_rate_service.list_rates()) == [new, old]


def test_manager_registers_rate_through_api(api_client: APIClient, manager: User) -> None:
    api_client.force_authenticate(manager)

    response = api_client.post(RATES_URL, {"usd_to_ves_rate": "151.2500"}, format="json")

    assert response.status_code == 201
    assert response.data["usd_to_ves_rate"] == "151.2500"
    assert response.data["created_by"] == manager.pk
    assert api_client.get(CURRENT_URL).data["id"] == response.data["id"]


def test_supervisor_can_read_but_not_register(api_client: APIClient, supervisor: User) -> None:
    ExchangeRateFactory()
    api_client.force_authenticate(supervisor)

    assert api_client.get(CURRENT_URL).status_code == 200
    listing = api_client.get(RATES_URL)
    assert listing.status_code == 200
    assert listing.data["count"] == 1
    assert api_client.post(RATES_URL, {"usd_to_ves_rate": "1"}, format="json").status_code == 403


def test_current_rate_api_without_rates(api_client: APIClient, supervisor: User) -> None:
    api_client.force_authenticate(supervisor)

    response = api_client.get(CURRENT_URL)

    assert response.status_code == 409
    assert response.data["code"] == "exchange_rate_not_set"


def test_api_rejects_invalid_rate(api_client: APIClient, manager: User) -> None:
    api_client.force_authenticate(manager)

    assert api_client.post(RATES_URL, {"usd_to_ves_rate": "abc"}, format="json").status_code == 400
    response = api_client.post(RATES_URL, {"usd_to_ves_rate": "0"}, format="json")
    assert response.status_code == 422
    assert response.data["code"] == "invalid_exchange_rate"
