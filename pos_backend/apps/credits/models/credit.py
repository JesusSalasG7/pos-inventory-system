"""Deuda que abre una venta a crédito. Se guarda y se cobra en USD."""

from django.db import models
from django.db.models import F, Q

from core.models import TimeStampedModel


class Credit(TimeStampedModel):
    sale = models.OneToOneField("sales.Sale", on_delete=models.PROTECT, related_name="credit")
    customer = models.ForeignKey(
        "credits.Customer", on_delete=models.PROTECT, related_name="credits"
    )
    branch = models.ForeignKey(
        "branches.Branch",
        to_field="code",
        db_column="branch",
        on_delete=models.PROTECT,
        related_name="credits",
    )
    # Lo que quedó a crédito al vender, en USD. Nunca cambia.
    amount_usd = models.DecimalField(max_digits=14, decimal_places=2)
    # Lo que falta por cobrar, en USD. Lo descuentan los abonos.
    balance_usd = models.DecimalField(max_digits=14, decimal_places=2)
    due_date = models.DateField()
    # Momento en que el saldo llegó a cero.
    paid_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        ordering = ["due_date", "id"]
        indexes = [
            models.Index(fields=["branch", "due_date"], name="credit_branch_due_idx"),
        ]
        constraints = [
            models.CheckConstraint(
                condition=Q(balance_usd__gte=0) & Q(balance_usd__lte=F("amount_usd")),
                name="credit_balance_within_amount",
            ),
        ]

    def __str__(self) -> str:
        return f"Credit #{self.pk} ({self.customer_id}): {self.balance_usd} USD"
