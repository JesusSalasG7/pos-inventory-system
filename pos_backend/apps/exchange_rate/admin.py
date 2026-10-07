from django.contrib import admin
from django.http import HttpRequest

from apps.exchange_rate.models import ExchangeRate, PricingSettings


@admin.register(ExchangeRate)
class ExchangeRateAdmin(admin.ModelAdmin):
    list_display = ("usd_to_ves_rate", "source", "effective_date", "created_by", "created_at")
    list_filter = ("source", "created_by")
    date_hierarchy = "created_at"


@admin.register(PricingSettings)
class PricingSettingsAdmin(admin.ModelAdmin):
    """Fila única: se edita, pero no se crea otra ni se borra."""

    list_display = ("rate_mode", "round_ves_up", "updated_at")

    def has_add_permission(self, request: HttpRequest) -> bool:
        return not PricingSettings.objects.exists()

    def has_delete_permission(self, request: HttpRequest, obj: object = None) -> bool:
        return False
