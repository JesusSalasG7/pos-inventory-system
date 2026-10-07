"""Línea de una venta, con el precio y el costo unitarios congelados."""

from django.db import models

from core.models import TimeStampedModel


class SaleDetail(TimeStampedModel):
    sale = models.ForeignKey("sales.Sale", on_delete=models.PROTECT, related_name="details")
    product = models.ForeignKey(
        "inventory.Product", on_delete=models.PROTECT, related_name="sale_details"
    )
    quantity = models.DecimalField(max_digits=12, decimal_places=3)
    unit_price_usd = models.DecimalField(max_digits=14, decimal_places=2)
    # Costo del producto al facturar: la ganancia de una venta pasada no cambia
    # aunque después se edite el costo en el catálogo.
    unit_cost_usd = models.DecimalField(max_digits=14, decimal_places=2)
    subtotal_usd = models.DecimalField(max_digits=14, decimal_places=2)
    # Lo facturado en bolívares por esta línea. Con el redondeo activo no es
    # `subtotal_usd × tasa`: el precio en VES se redondea hacia arriba.
    subtotal_ves = models.DecimalField(max_digits=14, decimal_places=2)

    def __str__(self) -> str:
        return f"Sale #{self.sale_id}: {self.quantity} x product {self.product_id}"
