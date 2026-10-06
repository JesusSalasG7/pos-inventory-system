from django.contrib import admin

from apps.exchange_rate.models import ExchangeRate


@admin.register(ExchangeRate)
class ExchangeRateAdmin(admin.ModelAdmin):
    list_display = ("usd_to_ves_rate", "source", "effective_date", "created_by", "created_at")
    list_filter = ("source", "created_by")
    date_hierarchy = "created_at"
