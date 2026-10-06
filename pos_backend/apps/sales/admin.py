from django.contrib import admin

from apps.sales.models import Sale, SaleDetail, SalePayment


@admin.register(Sale)
class SaleAdmin(admin.ModelAdmin):
    list_display = ("id", "branch", "user", "cash_session", "total_usd", "total_ves", "created_at")
    list_filter = ("branch", "user")
    search_fields = ("customer_tax_id", "customer_name")
    date_hierarchy = "created_at"


@admin.register(SaleDetail)
class SaleDetailAdmin(admin.ModelAdmin):
    list_display = ("sale", "product", "quantity", "unit_price_usd", "subtotal_usd")
    list_filter = ("product__category",)
    search_fields = ("product__name",)


@admin.register(SalePayment)
class SalePaymentAdmin(admin.ModelAdmin):
    list_display = ("sale", "method", "currency", "amount", "approval_reference")
    list_filter = ("method", "currency")
    search_fields = ("approval_reference",)
