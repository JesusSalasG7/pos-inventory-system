"""Configuración de precios del negocio: una sola fila."""

from django.db import models

from core.enums import RateMode
from core.models import TimeStampedModel


class PricingSettings(TimeStampedModel):
    """Cómo se obtienen los precios en bolívares. La fila única tiene `pk=1`."""

    # BCV: la tasa activa sigue a la del BCV. MANUAL: manda la que fije un MANAGER.
    rate_mode = models.CharField(max_length=10, choices=RateMode.choices, default=RateMode.BCV)
    # Los precios en VES se redondean hacia arriba al bolívar entero. Los de USD no cambian.
    round_ves_up = models.BooleanField(default=False)

    class Meta:
        verbose_name_plural = "pricing settings"

    def __str__(self) -> str:
        return f"Tasa {self.rate_mode}, redondeo VES {'sí' if self.round_ves_up else 'no'}"
