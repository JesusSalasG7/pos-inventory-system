"""Configuración de precios: con qué tasa se vende y si los bolívares se redondean."""

from django.db import transaction

from apps.exchange_rate.models import PricingSettings
from apps.exchange_rate.repositories import pricing_settings_repository
from core.enums import RateMode

EDITABLE_FIELDS = frozenset({"rate_mode", "round_ves_up"})


def get_settings() -> PricingSettings:
    """Devuelve la configuración vigente (por defecto: tasa BCV y sin redondeo)."""
    return pricing_settings_repository.get()


def update_settings(**fields: object) -> PricingSettings:
    """Cambia el modo de tasa o el redondeo en bolívares.

    - `rate_mode = BCV`: la tasa activa vuelve a seguir a la del BCV. Se
      registra de inmediato la del BCV como activa; si no se puede consultar,
      lanza `bcv_rate_unavailable` (503) y no se cambia nada.
    - `rate_mode = MANUAL`: la tasa activa se queda como está y el BCV deja de
      reemplazarla; el MANAGER fija la suya con `exchange_rate_service`.
    - `round_ves_up`: afecta solo a las ventas nuevas.
    """
    # Import local: bcv_rate_service consulta a su vez esta configuración.
    from apps.exchange_rate.services import bcv_rate_service

    unknown = fields.keys() - EDITABLE_FIELDS
    if unknown:
        raise ValueError(f"Campos no editables: {sorted(unknown)}")

    settings = get_settings()
    if not fields:
        return settings
    back_to_bcv = settings.rate_mode != RateMode.BCV and fields.get("rate_mode") == RateMode.BCV

    with transaction.atomic():
        settings = pricing_settings_repository.update(settings, **fields)
        if back_to_bcv:
            bcv_rate_service.sync_active_rate(replace_manual=True)
    return settings
