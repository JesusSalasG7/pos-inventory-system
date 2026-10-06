from django.contrib import admin
from django.http import HttpRequest

from apps.inventory.models import BranchInventory, InventoryMovement, Product


@admin.register(Product)
class ProductAdmin(admin.ModelAdmin):
    list_display = (
        "name",
        "category",
        "unit_of_measure",
        "cost_price_usd",
        "sale_price_usd",
        "active",
    )
    list_filter = ("category", "unit_of_measure", "active")
    search_fields = ("name",)


@admin.register(BranchInventory)
class BranchInventoryAdmin(admin.ModelAdmin):
    list_display = ("product", "branch", "current_stock", "minimum_stock")
    list_filter = ("branch",)
    search_fields = ("product__name",)
    # El stock solo cambia a través de stock_service, nunca desde el admin.
    readonly_fields = ("current_stock",)


@admin.register(InventoryMovement)
class InventoryMovementAdmin(admin.ModelAdmin):
    """El Kardex es de solo lectura: no se crea, edita ni borra desde el admin."""

    list_display = (
        "created_at",
        "product",
        "branch",
        "movement_type",
        "quantity",
        "stock_before",
        "stock_after",
        "user",
    )
    list_filter = ("branch", "movement_type")
    search_fields = ("product__name",)
    date_hierarchy = "created_at"

    def has_add_permission(self, request: HttpRequest) -> bool:
        return False

    def has_change_permission(self, request: HttpRequest, obj: object = None) -> bool:
        return False

    def has_delete_permission(self, request: HttpRequest, obj: object = None) -> bool:
        return False
