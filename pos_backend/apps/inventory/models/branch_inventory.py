"""Existencias de un producto en una sucursal física."""

from django.db import models
from django.db.models import Q

from core.models import TimeStampedModel


class BranchInventory(TimeStampedModel):
    product = models.ForeignKey(
        "inventory.Product", on_delete=models.PROTECT, related_name="branch_inventories"
    )
    branch = models.ForeignKey(
        "branches.Branch",
        to_field="code",
        db_column="branch",
        on_delete=models.PROTECT,
        related_name="inventories",
    )
    # Solo stock_service modifica este campo, siempre junto a un movimiento de Kardex.
    current_stock = models.DecimalField(max_digits=12, decimal_places=3, default=0)
    minimum_stock = models.DecimalField(max_digits=12, decimal_places=3, default=0)

    class Meta:
        verbose_name_plural = "branch inventories"
        constraints = [
            models.UniqueConstraint(
                fields=["product", "branch"], name="unique_branch_inventory_product_branch"
            ),
            models.CheckConstraint(
                condition=Q(current_stock__gte=0), name="branch_inventory_current_stock_gte_0"
            ),
        ]

    def __str__(self) -> str:
        return f"{self.product_id} @ {self.branch_id}: {self.current_stock}"
