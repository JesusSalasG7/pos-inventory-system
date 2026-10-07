"""Tasa oficial del BCV: consulta en DolarApi y sincronización automática.

`get_bcv_rate` sirve la tasa como referencia, con caché. `get_cost_rate` da la
que valora el costo de una venta. `sync_active_rate` la registra como tasa
activa cada vez que el BCV publica una nueva; lo ejecuta el comando programado
`sync_bcv_rate`.
"""

import json
import logging
from datetime import datetime
from decimal import ROUND_HALF_UP, Decimal, InvalidOperation

import requests
from django.core.cache import cache
from django.db import transaction
from django.utils import timezone

from apps.exchange_rate.domain.dtos import BcvRate
from apps.exchange_rate.models import ExchangeRate
from apps.exchange_rate.repositories import exchange_rate_repository
from core.enums import RateMode, RateSource
from core.exceptions import DomainError
from core.money import quantize_rate, to_decimal

logger = logging.getLogger(__name__)

BCV_RATE_URL = "https://ve.dolarapi.com/v1/dolares/oficial"
# El BCV publica más decimales, pero en la calle se cobra con dos: la tasa se
# guarda ya redondeada para que la que se muestra sea la misma con la que se cobra.
BCV_RATE_QUANTUM = Decimal("0.01")
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


def get_cost_rate() -> Decimal | None:
    """Devuelve la tasa del BCV con la que se pasa a bolívares el costo de una venta.

    El costo se valora siempre con el BCV, aunque el negocio venda con su
    propia tasa (`RateMode.MANUAL`) o un MANAGER haya fijado una manual.

    - En modo BCV es la última tasa de origen BCV registrada, que mantiene al
      día la sincronización. Si nunca se registró una, se consulta al BCV.
    - En modo MANUAL la sincronización no registra nada, así que se consulta
      al BCV (con caché) y, si falla, vale la última registrada.

    Nunca lanza una excepción: devuelve None si no hay ninguna tasa del BCV.
    """
    # Import local: pricing_settings_service llama a su vez a este módulo.
    from apps.exchange_rate.services import pricing_settings_service

    registered = exchange_rate_repository.get_latest_by_source(RateSource.BCV)
    follows_bcv = pricing_settings_service.get_settings().rate_mode == RateMode.BCV
    if follows_bcv and registered is not None:
        return registered.usd_to_ves_rate

    bcv_rate = get_bcv_rate()
    if bcv_rate is not None:
        return bcv_rate.rate
    return registered.usd_to_ves_rate if registered is not None else None


def sync_active_rate(*, replace_manual: bool = False) -> ExchangeRate | None:
    """Registra la tasa del BCV como tasa activa si el BCV publicó una nueva.

    Consulta siempre al BCV, sin pasar por la caché. Compara contra la última
    tasa de origen BCV registrada, no contra la activa: así una tasa manual de
    un MANAGER se respeta hasta que el BCV publique la siguiente.

    Si el negocio vende con su propia tasa (`RateMode.MANUAL`) no registra
    nada: el BCV no reemplaza la tasa del MANAGER.

    Con `replace_manual` compara contra la tasa activa, sea cual sea su
    origen: la del BCV pasa a ser la activa aunque no haya cambiado. Lo usa
    `pricing_settings_service` al volver del modo manual al del BCV.

    Devuelve la tasa creada, o None si no había nada que registrar. Lanza
    `bcv_rate_unavailable` (503) si no se pudo consultar: no se registra nada.
    """
    # Import local: pricing_settings_service llama a su vez a esta función.
    from apps.exchange_rate.services import pricing_settings_service

    if pricing_settings_service.get_settings().rate_mode == RateMode.MANUAL:
        return None

    try:
        bcv_rate = _fetch_bcv_rate()
    except (requests.RequestException, ValueError, TypeError, KeyError, InvalidOperation) as exc:
        logger.exception("No se pudo sincronizar la tasa del BCV desde %s.", BCV_RATE_URL)
        raise DomainError(
            "No se pudo obtener la tasa del BCV. Intente de nuevo más tarde.",
            code="bcv_rate_unavailable",
            status_code=503,
        ) from exc
    cache.set(CACHE_KEY, bcv_rate, CACHE_SECONDS)
    cache.set(LAST_KNOWN_CACHE_KEY, bcv_rate, None)

    effective_date = timezone.localtime(bcv_rate.updated_at).date()
    with transaction.atomic():
        last = (
            exchange_rate_repository.get_latest()
            if replace_manual
            else exchange_rate_repository.get_latest_by_source(RateSource.BCV)
        )
        if (
            last is not None
            and last.source == RateSource.BCV
            and last.usd_to_ves_rate == bcv_rate.rate
            and last.effective_date == effective_date
        ):
            return None
        return exchange_rate_repository.create(
            usd_to_ves_rate=bcv_rate.rate,
            source=RateSource.BCV,
            effective_date=effective_date,
        )


def _fetch_bcv_rate() -> BcvRate:
    """Consulta DolarApi y valida la respuesta; lanza una excepción si no es utilizable."""
    response = requests.get(BCV_RATE_URL, timeout=REQUEST_TIMEOUT_SECONDS)
    response.raise_for_status()
    # Los decimales se leen directamente como Decimal para no pasar por float.
    payload = json.loads(response.text, parse_float=Decimal)

    rate = quantize_rate(
        to_decimal(payload["promedio"]).quantize(BCV_RATE_QUANTUM, rounding=ROUND_HALF_UP)
    )
    if rate <= 0:
        raise ValueError(f"Tasa no válida en la respuesta: {payload['promedio']!r}.")

    updated_at = datetime.fromisoformat(payload["fechaActualizacion"])
    if timezone.is_naive(updated_at):
        updated_at = timezone.make_aware(updated_at)
    return BcvRate(rate=rate, updated_at=updated_at)
