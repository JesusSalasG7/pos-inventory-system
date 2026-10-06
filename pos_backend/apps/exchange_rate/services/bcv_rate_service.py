"""Consulta de la tasa oficial del BCV en DolarApi, protegida con caché.

La tasa obtenida aquí es solo una referencia: la tasa con la que se factura
sigue siendo la que registra un MANAGER con `exchange_rate_service`.
"""

import json
import logging
from datetime import datetime
from decimal import Decimal, InvalidOperation

import requests
from django.core.cache import cache
from django.utils import timezone

from apps.exchange_rate.domain.dtos import BcvRate
from core.exceptions import DomainError
from core.money import quantize_rate

logger = logging.getLogger(__name__)

BCV_RATE_URL = "https://ve.dolarapi.com/v1/dolares/oficial"
REQUEST_TIMEOUT_SECONDS = 5
CACHE_SECONDS = 6 * 60 * 60
# Tras un fallo no se reintenta en cada petición: se espera este tiempo.
RETRY_SECONDS = 5 * 60

CACHE_KEY = "exchange_rate:bcv_rate"
LAST_KNOWN_CACHE_KEY = "exchange_rate:bcv_rate:last_known"
RETRY_CACHE_KEY = "exchange_rate:bcv_rate:retry_wait"


def get_bcv_rate() -> BcvRate | None:
    """Devuelve la tasa oficial del BCV, consultando la API como mucho cada 6 horas.

    Nunca lanza una excepción: si la API falla o su JSON cambia, registra el
    error y devuelve la última tasa conocida, o None si nunca se obtuvo una.
    """
    cached: BcvRate | None = cache.get(CACHE_KEY)
    if cached is not None:
        return cached
    if cache.get(RETRY_CACHE_KEY):
        return cache.get(LAST_KNOWN_CACHE_KEY)

    try:
        bcv_rate = _fetch_bcv_rate()
    except (requests.RequestException, ValueError, TypeError, KeyError, InvalidOperation):
        logger.exception("No se pudo obtener la tasa del BCV desde %s.", BCV_RATE_URL)
        cache.set(RETRY_CACHE_KEY, True, RETRY_SECONDS)
        return cache.get(LAST_KNOWN_CACHE_KEY)

    cache.set(CACHE_KEY, bcv_rate, CACHE_SECONDS)
    cache.set(LAST_KNOWN_CACHE_KEY, bcv_rate, None)
    return bcv_rate


def get_bcv_rate_or_fail() -> BcvRate:
    """Como `get_bcv_rate`, pero lanza `bcv_rate_unavailable` (503) si no hay tasa."""
    bcv_rate = get_bcv_rate()
    if bcv_rate is None:
        raise DomainError(
            "No se pudo obtener la tasa del BCV. Intente de nuevo más tarde.",
            code="bcv_rate_unavailable",
            status_code=503,
        )
    return bcv_rate


def _fetch_bcv_rate() -> BcvRate:
    """Consulta DolarApi y valida la respuesta; lanza una excepción si no es utilizable."""
    response = requests.get(BCV_RATE_URL, timeout=REQUEST_TIMEOUT_SECONDS)
    response.raise_for_status()
    # Los decimales se leen directamente como Decimal para no pasar por float.
    payload = json.loads(response.text, parse_float=Decimal)

    rate = quantize_rate(payload["promedio"])
    if rate <= 0:
        raise ValueError(f"Tasa no válida en la respuesta: {payload['promedio']!r}.")

    updated_at = datetime.fromisoformat(payload["fechaActualizacion"])
    if timezone.is_naive(updated_at):
        updated_at = timezone.make_aware(updated_at)
    return BcvRate(rate=rate, updated_at=updated_at)
