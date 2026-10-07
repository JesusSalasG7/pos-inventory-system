"""Acceso a datos de la configuración de precios."""

from apps.exchange_rate.models import PricingSettings

SINGLETON_ID = 1


def get() -> PricingSettings:
    """Devuelve la configuración; la crea con los valores por defecto si no existe."""
    settings, _ = PricingSettings.objects.get_or_create(pk=SINGLETON_ID)
    return settings


def update(settings: PricingSettings, **fields: object) -> PricingSettings:
    """Actualiza solo los campos indicados usando `update_fields`."""
    for field, value in fields.items():
        setattr(settings, field, value)
    settings.save(update_fields=[*fields, "updated_at"])
    return settings
