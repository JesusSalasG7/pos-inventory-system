from django.apps import AppConfig


class ExchangeRateConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "apps.exchange_rate"
    label = "exchange_rate"
    verbose_name = "Tasa de cambio"
