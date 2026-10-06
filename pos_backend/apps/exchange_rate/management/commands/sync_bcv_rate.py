"""Sincroniza la tasa activa con la del BCV. Pensado para ejecutarse con cron."""

from typing import Any

from django.core.management.base import BaseCommand, CommandError

from apps.exchange_rate.services import bcv_rate_service
from core.exceptions import DomainError


class Command(BaseCommand):
    help = "Registra la tasa del BCV como tasa activa si el BCV publicó una nueva."

    def handle(self, *args: Any, **options: Any) -> None:
        try:
            created = bcv_rate_service.sync_active_rate()
        except DomainError as exc:
            # Código de salida distinto de cero: cron puede avisar del fallo.
            raise CommandError(exc.detail) from exc

        if created is None:
            self.stdout.write("La tasa del BCV no cambió.")
            return
        self.stdout.write(
            self.style.SUCCESS(
                f"Tasa del BCV registrada: {created.usd_to_ves_rate} VES/USD "
                f"(corresponde al {created.effective_date:%d/%m/%Y})."
            )
        )
