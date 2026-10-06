"""Reglas de negocio de la tasa de cambio USD → VES."""

from decimal import Decimal

from django.db.models import QuerySet

from apps.auth.models import User
from apps.exchange_rate.models import ExchangeRate
from apps.exchange_rate.repositories import exchange_rate_repository
from core.exceptions import DomainError
from core.money import quantize_rate


def get_active_rate() -> ExchangeRate:
    """Devuelve la tasa activa, que es la más reciente registrada.

    Si todavía no se ha registrado ninguna, lanza un DomainError con código
    `exchange_rate_not_set` (409): sin tasa no se puede facturar.
    """
    rate = exchange_rate_repository.get_latest()
    if rate is None:
        raise DomainError(
            "Todavía no se ha registrado una tasa de cambio.",
            code="exchange_rate_not_set",
            status_code=409,
        )
    return rate


def register_rate(*, usd_to_ves_rate: Decimal, user: User) -> ExchangeRate:
    """Registra una nueva tasa, que pasa a ser la activa.

    La tasa se redondea a 4 decimales y debe quedar mayor que cero. Nunca se
    edita una tasa existente, para conservar el histórico: las ventas ya
    facturadas mantienen su tasa congelada.
    """
    rate = quantize_rate(usd_to_ves_rate)
    if rate <= 0:
        raise DomainError(
            "La tasa de cambio debe ser mayor que cero.",
            code="invalid_exchange_rate",
            status_code=422,
            meta={"usd_to_ves_rate": str(usd_to_ves_rate)},
        )
    return exchange_rate_repository.create(usd_to_ves_rate=rate, created_by=user)


def list_rates() -> QuerySet[ExchangeRate]:
    """Lista el histórico de tasas."""
    return exchange_rate_repository.list_all()
