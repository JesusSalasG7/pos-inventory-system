"""Cabecera de la venta. Los totales y las tasas quedan congelados al facturar."""

from django.conf import settings
from django.db import models

from core.models import TimeStampedModel


class Sale(TimeStampedModel):
    # La FK ya crea el índice sobre cash_session; no se declara otro en Meta.indexes.
    cash_session = models.ForeignKey(
        "cash_sessions.CashSession", on_delete=models.PROTECT, related_name="sales"
    )
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.PROTECT, related_name="sales"
    )
    branch = models.ForeignKey(
        "branches.Branch",
        to_field="code",
        db_column="branch",
        on_delete=models.PROTECT,
        related_name="sales",
    )
    customer_tax_id = models.CharField(max_length=20, blank=True)
    customer_name = models.CharField(max_length=150, blank=True)
    exchange_rate_at_invoice = models.DecimalField(max_digits=14, decimal_places=4)
    # Tasa del BCV al facturar: con ella se pasa el costo a bolívares, aunque la
    # venta se haya cobrado con una tasa manual.
    bcv_rate_at_invoice = models.DecimalField(max_digits=14, decimal_places=4)
    total_usd = models.DecimalField(max_digits=14, decimal_places=2)
    total_ves = models.DecimalField(max_digits=14, decimal_places=2)

    class Meta:
        ordering = ["-created_at", "-id"]
        indexes = [
            models.Index(fields=["branch", "created_at"], name="sale_branch_created_idx"),
        ]

    def __str__(self) -> str:
        return f"Sale #{self.pk} ({self.branch_id}): {self.total_usd} USD"
