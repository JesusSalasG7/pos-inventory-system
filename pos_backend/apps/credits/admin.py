from django.contrib import admin
from django.http import HttpRequest

from apps.credits.models import Credit, CreditPayment, CreditPaymentAllocation, Customer


@admin.register(Customer)
class CustomerAdmin(admin.ModelAdmin):
    list_display = ("name", "tax_id", "phone", "credit_days", "active")
    list_filter = ("active",)
    search_fields = ("name", "tax_id", "phone")

    # Los clientes no se borran: se desactivan.
    def has_delete_permission(self, request: HttpRequest, obj: object = None) -> bool:
        return False


class ReadOnlyAdmin(admin.ModelAdmin):
    """Deudas y abonos solo cambian por la API: aquí se consultan."""

    def has_add_permission(self, request: HttpRequest) -> bool:
        return False

    def has_change_permission(self, request: HttpRequest, obj: object = None) -> bool:
        return False

    def has_delete_permission(self, request: HttpRequest, obj: object = None) -> bool:
        return False


@admin.register(Credit)
class CreditAdmin(ReadOnlyAdmin):
    list_display = ("id", "customer", "branch", "amount_usd", "balance_usd", "due_date", "paid_at")
    list_filter = ("branch",)
    search_fields = ("customer__name", "customer__tax_id")


@admin.register(CreditPayment)
class CreditPaymentAdmin(ReadOnlyAdmin):
    list_display = ("id", "customer", "branch", "method", "amount", "currency", "amount_usd")
    list_filter = ("branch", "method")
    search_fields = ("customer__name", "approval_reference")
    date_hierarchy = "created_at"


@admin.register(CreditPaymentAllocation)
class CreditPaymentAllocationAdmin(ReadOnlyAdmin):
    list_display = ("payment", "credit", "amount_usd")
