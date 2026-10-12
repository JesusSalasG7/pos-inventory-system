"""Parte de un abono aplicada a una deuda concreta."""

from django.db import models

from core.models import TimeStampedModel


class CreditPaymentAllocation(TimeStampedModel):
    payment = models.ForeignKey(
        "credits.CreditPayment", on_delete=models.PROTECT, related_name="allocations"
    )
    credit = models.ForeignKey(
        "credits.Credit", on_delete=models.PROTECT, related_name="allocations"
    )
    amount_usd = models.DecimalField(max_digits=14, decimal_places=2)

    def __str__(self) -> str:
        return f"Payment #{self.payment_id} → credit #{self.credit_id}: {self.amount_usd} USD"
