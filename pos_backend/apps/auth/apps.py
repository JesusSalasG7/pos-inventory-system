from django.apps import AppConfig


class AccountsConfig(AppConfig):
    default_auto_field = "django.db.models.BigAutoField"
    name = "apps.auth"
    # El label evita el choque con django.contrib.auth (label "auth").
    label = "accounts"
    verbose_name = "Usuarios"
