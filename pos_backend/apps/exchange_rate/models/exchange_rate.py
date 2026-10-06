"""Histórico de la tasa de cambio USD → VES."""

from django.conf import settings
from django.db import models
from django.db.models import Q

from core.enums import RateSource


class ExchangeRate(models.Model):
    """La tasa activa es siempre la fila más reciente; nunca se edita una existente."""

    # Cantidad de VES equivalente a 1 USD.
    usd_to_ves_rate = models.DecimalField(max_digits=14, decimal_places=4)
    # MANUAL la registra un MANAGER; BCV la registra la sincronización automática.
    source = models.CharField(max_length=10, choices=RateSource.choices, default=RateSource.MANUAL)
    # Día al que corresponde la tasa según el BCV. Vacío en las tasas manuales.
    effective_date = models.DateField(null=True, blank=True)
    # Vacío en las tasas automáticas: no las registra ningún usuario.
    created_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.PROTECT,
        related_name="exchange_rates",
        null=True,
        blank=True,
    )
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["-created_at", "-id"]
        get_latest_by = "created_at"
        indexes = [
            models.Index(fields=["-created_at"], name="exchange_rate_created_idx"),
        ]
        constraints = [
            models.CheckConstraint(
                condition=Q(usd_to_ves_rate__gt=0), name="exchange_rate_usd_to_ves_rate_gt_0"
            ),
        ]

    def __str__(self) -> str:
        return f"{self.usd_to_ves_rate} VES/USD ({self.created_at:%Y-%m-%d %H:%M})"
