"""Pago de una venta. Una venta admite varios métodos y monedas."""

from django.db import models

from core.enums import Currency, PaymentMethod
from core.models import TimeStampedModel


class SalePayment(TimeStampedModel):
    sale = models.ForeignKey("sales.Sale", on_delete=models.PROTECT, related_name="payments")
    method = models.CharField(max_length=20, choices=PaymentMethod.choices)
    currency = models.CharField(max_length=3, choices=Currency.choices)
    amount = models.DecimalField(max_digits=14, decimal_places=2)
    approval_reference = models.CharField(max_length=50, blank=True)

    def __str__(self) -> str:
        return f"Sale #{self.sale_id}: {self.amount} {self.currency} ({self.method})"
