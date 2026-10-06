"""Acceso a datos del histórico de tasas."""

from datetime import date
from decimal import Decimal

from django.db.models import QuerySet

from apps.auth.models import User
from apps.exchange_rate.models import ExchangeRate
from core.enums import RateSource


def get_latest() -> ExchangeRate | None:
    """Devuelve la tasa más reciente (la activa), o None si no hay ninguna."""
    return ExchangeRate.objects.order_by("-created_at", "-id").first()


def get_latest_by_source(source: RateSource) -> ExchangeRate | None:
    """Devuelve la tasa más reciente de un origen, o None si no hay ninguna."""
    return ExchangeRate.objects.filter(source=source).order_by("-created_at", "-id").first()


def create(
    *,
    usd_to_ves_rate: Decimal,
    created_by: User | None = None,
    source: RateSource = RateSource.MANUAL,
    effective_date: date | None = None,
) -> ExchangeRate:
    """Inserta una nueva tasa, que pasa a ser la activa."""
    return ExchangeRate.objects.create(
        usd_to_ves_rate=usd_to_ves_rate,
        created_by=created_by,
        source=source,
        effective_date=effective_date,
    )


def list_all() -> QuerySet[ExchangeRate]:
    """Lista el histórico de tasas, de la más reciente a la más antigua."""
    return ExchangeRate.objects.order_by("-created_at", "-id")
