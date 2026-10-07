from datetime import datetime
from decimal import Decimal
from unittest.mock import Mock, patch

import pytest
import requests
from django.core.cache import cache

from apps.exchange_rate.services import bcv_rate_service

VALID_BODY = (
    '{"moneda": "USD", "fuente": "oficial", "promedio": 872.39275, '
    '"fechaActualizacion": "2026-10-06T00:00:00-04:00"}'
)


@pytest.fixture(autouse=True)
def clean_cache() -> None:
    cache.clear()
    yield
    cache.clear()


def _response(body: str, status_code: int = 200) -> Mock:
    response = Mock(text=body, status_code=status_code)
    if status_code >= 400:
        response.raise_for_status.side_effect = requests.HTTPError(f"{status_code}")
    return response


def _patch_get(**kwargs: object):
    return patch.object(bcv_rate_service.requests, "get", **kwargs)


def test_returns_rate_as_decimal_with_aware_datetime() -> None:
    with _patch_get(return_value=_response(VALID_BODY)):
        result = bcv_rate_service.get_bcv_rate()

    assert result.rate == Decimal("872.3900")  # 2 decimales, como se cobra; sin pasar por float
    assert isinstance(result.rate, Decimal)
    assert result.updated_at == datetime.fromisoformat("2026-10-06T00:00:00-04:00")
    assert result.updated_at.tzinfo is not None


def test_second_call_uses_cache() -> None:
    with _patch_get(return_value=_response(VALID_BODY)) as get:
        first = bcv_rate_service.get_bcv_rate()
        second = bcv_rate_service.get_bcv_rate()

    assert first == second
    assert get.call_count == 1


@pytest.mark.parametrize(
    "get_kwargs",
    [
        {"side_effect": requests.ConnectionError("sin red")},
        {"side_effect": requests.Timeout("tiempo agotado")},
        {"return_value": _response("error", status_code=503)},
        {"return_value": _response("<html>no es json</html>")},
        {"return_value": _response("[]")},
        {"return_value": _response('{"fechaActualizacion": "2026-10-06T00:00:00-04:00"}')},
        {"return_value": _response('{"promedio": null, "fechaActualizacion": "2026-10-06"}')},
        {"return_value": _response('{"promedio": "abc", "fechaActualizacion": "2026-10-06"}')},
        {"return_value": _response('{"promedio": 0, "fechaActualizacion": "2026-10-06"}')},
        {"return_value": _response('{"promedio": 872.39, "fechaActualizacion": "ayer"}')},
        {"return_value": _response('{"promedio": 872.39}')},
    ],
)
def test_failure_returns_none_and_logs(get_kwargs: dict, caplog: pytest.LogCaptureFixture) -> None:
    with _patch_get(**get_kwargs):
        assert bcv_rate_service.get_bcv_rate() is None

    assert "No se pudo obtener la tasa del BCV" in caplog.text


def test_failure_is_not_retried_on_every_call() -> None:
    with _patch_get(side_effect=requests.ConnectionError("sin red")) as get:
        bcv_rate_service.get_bcv_rate()
        bcv_rate_service.get_bcv_rate()

    assert get.call_count == 1


def test_failure_falls_back_to_last_known_rate() -> None:
    with _patch_get(return_value=_response(VALID_BODY)):
        known = bcv_rate_service.get_bcv_rate()
    # Simula que pasaron las 6 horas de vigencia.
    cache.delete(bcv_rate_service.CACHE_KEY)

    with _patch_get(side_effect=requests.ConnectionError("sin red")):
        assert bcv_rate_service.get_bcv_rate() == known
