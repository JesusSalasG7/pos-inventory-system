"""Kardex: bitácora de movimientos de inventario (solo inserción)."""

from django.conf import settings
from django.db import models

from core.enums import MovementType


class InventoryMovement(models.Model):
    """Cada fila es inmutable; los errores se corrigen con un ADJUSTMENT."""

    product = models.ForeignKey(
        "inventory.Product", on_delete=models.PROTECT, related_name="movements"
    )
    branch = models.ForeignKey(
        "branches.Branch",
        to_field="code",
        db_column="branch",
        on_delete=models.PROTECT,
        related_name="inventory_movements",
    )
    movement_type = models.CharField(max_length=20, choices=MovementType.choices)
    # Siempre la magnitud positiva del movimiento; el sentido lo dan el tipo y
    # la pareja stock_before / stock_after.
    quantity = models.DecimalField(max_digits=12, decimal_places=3)
    stock_before = models.DecimalField(max_digits=12, decimal_places=3)
    stock_after = models.DecimalField(max_digits=12, decimal_places=3)
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL, on_delete=models.PROTECT, related_name="inventory_movements"
    )
    sale = models.ForeignKey(
        "sales.Sale",
        on_delete=models.PROTECT,
        related_name="inventory_movements",
        null=True,
        blank=True,
    )
    notes = models.CharField(max_length=255, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["-created_at", "-id"]
        indexes = [
            models.Index(
                fields=["branch", "product", "created_at"], name="inv_mov_branch_prod_date_idx"
            ),
        ]

    def __str__(self) -> str:
        return f"{self.movement_type} {self.quantity} (product {self.product_id}, {self.branch_id})"
