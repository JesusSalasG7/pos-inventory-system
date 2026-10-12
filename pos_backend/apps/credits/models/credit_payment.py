"""Abono de un cliente a sus deudas. Entra en la caja abierta de quien lo cobra."""

from django.conf import settings
from django.db import models

from core.enums import Currency, PaymentMethod
from core.models import TimeStampedModel


class CreditPayment(TimeStampedModel):
    customer = models.ForeignKey(
        "credits.Customer", on_delete=models.PROTECT, related_name="payments"
    )
    cash_session = models.ForeignKey(
        "cash_sessions.CashSession", on_delete=models.PROTECT, related_name="credit_payments"
    )
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.PROTECT, related_name="credit_payments"
    )
    branch = models.ForeignKey(
        "branches.Branch",
        to_field="code",
        db_column="branch",
        on_delete=models.PROTECT,
        related_name="credit_payments",
    )
    method = models.CharField(max_length=20, choices=PaymentMethod.choices)
    currency = models.CharField(max_length=3, choices=Currency.choices)
    # Lo recibido, en la moneda del método.
    amount = models.DecimalField(max_digits=14, decimal_places=2)
    approval_reference = models.CharField(max_length=50, blank=True)
    # Tasa del BCV del día del abono: con ella se pasan a USD los bolívares recibidos.
    usd_to_ves_rate = models.DecimalField(max_digits=14, decimal_places=4)
    # Lo que el abono descontó de la deuda, en USD.
    amount_usd = models.DecimalField(max_digits=14, decimal_places=2)

    class Meta:
        ordering = ["-created_at", "-id"]

    def __str__(self) -> str:
        return f"Credit payment #{self.pk} ({self.customer_id}): {self.amount} {self.currency}"
