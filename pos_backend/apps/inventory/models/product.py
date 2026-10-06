"""Catálogo global de productos, compartido por todas las sucursales."""

from django.db import models
from django.db.models import Q

from core.enums import ProductCategory, UnitOfMeasure
from core.models import TimeStampedModel


class Product(TimeStampedModel):
    name = models.CharField(max_length=150)
    category = models.CharField(max_length=20, choices=ProductCategory.choices)
    unit_of_measure = models.CharField(max_length=20, choices=UnitOfMeasure.choices)
    cost_price_usd = models.DecimalField(max_digits=14, decimal_places=2)
    sale_price_usd = models.DecimalField(max_digits=14, decimal_places=2)
    # Los productos no se borran: se desactivan.
    active = models.BooleanField(default=True)

    class Meta:
        ordering = ["name"]
        constraints = [
            models.CheckConstraint(
                condition=Q(cost_price_usd__gte=0), name="product_cost_price_usd_gte_0"
            ),
            models.CheckConstraint(
                condition=Q(sale_price_usd__gte=0), name="product_sale_price_usd_gte_0"
            ),
        ]

    def __str__(self) -> str:
        return self.name
