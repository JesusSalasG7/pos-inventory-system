from rest_framework import serializers

from apps.inventory.models import BranchInventory, InventoryMovement, Product
from core.enums import MovementType


class ProductSerializer(serializers.ModelSerializer):
    class Meta:
        model = Product
        fields = [
            "id",
            "name",
            "category",
            "unit_of_measure",
            "cost_price_usd",
            "sale_price_usd",
            "active",
        ]
        read_only_fields = ["id", "active"]


class BranchInventorySerializer(serializers.ModelSerializer):
    product_name = serializers.CharField(source="product.name", read_only=True)
    branch = serializers.CharField(source="branch_id", read_only=True)

    class Meta:
        model = BranchInventory
        fields = ["id", "product", "product_name", "branch", "current_stock", "minimum_stock"]
        read_only_fields = fields


class MinimumStockSerializer(serializers.Serializer):
    branch = serializers.CharField(max_length=20, required=False)
    minimum_stock = serializers.DecimalField(max_digits=12, decimal_places=3, min_value=0)


class InventoryMovementSerializer(serializers.ModelSerializer):
    branch = serializers.CharField(source="branch_id", read_only=True)

    class Meta:
        model = InventoryMovement
        fields = [
            "id",
            "product",
            "branch",
            "movement_type",
            "quantity",
            "stock_before",
            "stock_after",
            "user",
            "sale",
            "notes",
            "created_at",
        ]
        read_only_fields = fields


class InventoryMovementCreateSerializer(serializers.Serializer):
    """Entrada, merma o ajuste manual. Las ventas generan su Kardex solas."""

    product_id = serializers.IntegerField(min_value=1)
    branch = serializers.CharField(max_length=20, required=False)
    movement_type = serializers.ChoiceField(
        choices=[MovementType.ENTRY, MovementType.WASTE, MovementType.ADJUSTMENT]
    )
    quantity = serializers.DecimalField(
        max_digits=12,
        decimal_places=3,
        min_value=0,
        help_text="Cantidad que entra o se pierde. En un ADJUSTMENT es el stock contado.",
    )
    notes = serializers.CharField(max_length=255, required=False, allow_blank=True)
