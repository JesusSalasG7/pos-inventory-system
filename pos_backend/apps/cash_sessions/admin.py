from django.contrib import admin

from apps.cash_sessions.models import CashExpense, CashSession


@admin.register(CashSession)
class CashSessionAdmin(admin.ModelAdmin):
    list_display = (
        "id",
        "user",
        "branch",
        "opened_at",
        "closed_at",
        "opening_float",
        "difference_usd",
    )
    list_filter = ("branch", "user")
    date_hierarchy = "opened_at"


@admin.register(CashExpense)
class CashExpenseAdmin(admin.ModelAdmin):
    list_display = ("cash_session", "reason", "amount", "currency", "created_by", "created_at")
    list_filter = ("currency",)
    search_fields = ("reason",)
