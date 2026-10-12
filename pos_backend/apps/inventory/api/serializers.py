from rest_framework import serializers

from apps.inventory.models import (
    BranchInventory,
    Category,
    InventoryMovement,
    Product,
    Subcategory,
)
from core.enums import MovementType


class CategorySerializer(serializers.ModelSerializer):
    class Meta:
        model = Category
        fields = ["id", "name", "icon", "active"]
        read_only_fields = fields


class CategoryCreateSerializer(serializers.Serializer):
    name = serializers.CharField(max_length=100)
    icon = serializers.CharField(
        max_length=16, required=False, allow_blank=True, help_text="Emoji; vacío para automático."
    )


class CategoryUpdateSerializer(serializers.Serializer):
    name = serializers.CharField(max_length=100, required=False)
    icon = serializers.CharField(max_length=16, required=False, allow_blank=True)
    active = serializers.BooleanField(required=False)


class SubcategorySerializer(serializers.ModelSerializer):
    category = serializers.IntegerField(source="category_id", read_only=True)

    class Meta:
        model = Subcategory
        fields = ["id", "category", "name", "active"]
        read_only_fields = fields


class SubcategoryCreateSerializer(serializers.Serializer):
    category = serializers.IntegerField(min_value=1)
    name = serializers.CharField(max_length=100)


class SubcategoryUpdateSerializer(serializers.Serializer):
    name = serializers.CharField(max_length=100, required=False)
    active = serializers.BooleanField(required=False)


class SubcategoryListQuerySerializer(serializers.Serializer):
    category = serializers.IntegerField(min_value=1, required=False)


class ProductSerializer(serializers.ModelSerializer):
    # La categoría viaja como su id; el nombre va aparte para no pedirla otra vez.
    category = serializers.IntegerField(source="category_id", min_value=1)
    category_name = serializers.CharField(source="category.name", read_only=True)
    category_icon = serializers.CharField(source="category.icon", read_only=True)
    # Opcional: `null` deja el producto sin subcategoría.
    subcategory = serializers.IntegerField(
        source="subcategory_id", min_value=1, required=False, allow_null=True
    )
    subcategory_name = serializers.CharField(
        source="subcategory.name", read_only=True, allow_null=True
    )

    class Meta:
        model = Product
        fields = [
            "id",
            "name",
            "category",
            "category_name",
            "category_icon",
            "subcategory",
            "subcategory_name",
            "unit_of_measure",
            "cost_price_usd",
            "sale_price_usd",
            "active",
        ]
        read_only_fields = ["id", "active"]


class ProductListQuerySerializer(serializers.Serializer):
    category = serializers.IntegerField(min_value=1, required=False)
    subcategory = serializers.IntegerField(min_value=1, required=False)


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
