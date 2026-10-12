"""Cliente al que se le puede vender a crédito."""

from django.conf import settings
from django.db import models
from django.db.models import Q

from core.models import TimeStampedModel


class Customer(TimeStampedModel):
    name = models.CharField(max_length=150)
    # Cédula o RIF. Opcional, pero no se repite entre clientes.
    tax_id = models.CharField(max_length=20, blank=True, default="")
    phone = models.CharField(max_length=30, blank=True, default="")
    # Plazo que se propone al venderle a crédito; cada venta puede usar otro.
    credit_days = models.PositiveSmallIntegerField(default=7)
    # Los clientes no se borran: se desactivan.
    active = models.BooleanField(default=True)
    created_by = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.PROTECT,
        null=True,
        blank=True,
        related_name="customers_created",
    )

    class Meta:
        ordering = ["name", "id"]
        constraints = [
            models.UniqueConstraint(
                fields=["tax_id"], condition=~Q(tax_id=""), name="unique_customer_tax_id"
            ),
        ]

    def __str__(self) -> str:
        return self.name
