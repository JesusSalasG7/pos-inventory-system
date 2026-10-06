"""Turno de caja: desde la apertura hasta el arqueo y cierre."""

from django.conf import settings
from django.db import models
from django.db.models import Q
from django.utils import timezone

from core.models import TimeStampedModel


class CashSession(TimeStampedModel):
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.PROTECT, related_name="cash_sessions"
    )
    branch = models.ForeignKey(
        "branches.Branch",
        to_field="code",
        db_column="branch",
        on_delete=models.PROTECT,
        related_name="cash_sessions",
    )
    opened_at = models.DateTimeField(default=timezone.now)
    closed_at = models.DateTimeField(null=True, blank=True)
    # Fondo inicial de caja, expresado en USD.
    opening_float = models.DecimalField(max_digits=14, decimal_places=2, default=0)
    # Se completan en el arqueo de cierre.
    counted_amount_usd = models.DecimalField(max_digits=14, decimal_places=2, null=True, blank=True)
    counted_amount_ves = models.DecimalField(max_digits=14, decimal_places=2, null=True, blank=True)
    difference_usd = models.DecimalField(max_digits=14, decimal_places=2, null=True, blank=True)

    class Meta:
        ordering = ["-opened_at"]
        constraints = [
            # Un usuario solo puede tener una caja abierta a la vez.
            models.UniqueConstraint(
                fields=["user"],
                condition=Q(closed_at__isnull=True),
                name="unique_open_cash_session_per_user",
            ),
        ]

    def __str__(self) -> str:
        state = "open" if self.closed_at is None else "closed"
        return f"CashSession #{self.pk} ({self.branch_id}, {state})"

    @property
    def is_open(self) -> bool:
        return self.closed_at is None
