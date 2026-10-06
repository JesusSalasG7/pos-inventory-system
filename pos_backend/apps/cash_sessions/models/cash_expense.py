"""Egreso de efectivo registrado durante un turno de caja."""

from django.conf import settings
from django.db import models

from core.enums import Currency
from core.models import TimeStampedModel


class CashExpense(TimeStampedModel):
    cash_session = models.ForeignKey(
        "cash_sessions.CashSession", on_delete=models.PROTECT, related_name="expenses"
    )
    reason = models.CharField(max_length=255)
    amount = models.DecimalField(max_digits=14, decimal_places=2)
    currency = models.CharField(max_length=3, choices=Currency.choices)
    created_by = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.PROTECT, related_name="cash_expenses"
    )

    class Meta:
        ordering = ["-created_at"]

    def __str__(self) -> str:
        return f"{self.reason}: {self.amount} {self.currency}"
