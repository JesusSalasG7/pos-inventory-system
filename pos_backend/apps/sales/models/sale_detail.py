"""Línea de una venta, con el precio unitario congelado."""

from django.db import models

from core.models import TimeStampedModel


class SaleDetail(TimeStampedModel):
    sale = models.ForeignKey("sales.Sale", on_delete=models.PROTECT, related_name="details")
    product = models.ForeignKey(
        "inventory.Product", on_delete=models.PROTECT, related_name="sale_details"
    )
    quantity = models.DecimalField(max_digits=12, decimal_places=3)
    unit_price_usd = models.DecimalField(max_digits=14, decimal_places=2)
    subtotal_usd = models.DecimalField(max_digits=14, decimal_places=2)

    def __str__(self) -> str:
        return f"Sale #{self.sale_id}: {self.quantity} x product {self.product_id}"
