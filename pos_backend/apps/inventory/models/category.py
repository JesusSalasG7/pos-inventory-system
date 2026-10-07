"""Categorías del catálogo. Las crea y administra un MANAGER."""

from django.db import models

from core.models import TimeStampedModel


class Category(TimeStampedModel):
    name = models.CharField(max_length=100, unique=True)
    # Sticker (emoji) que elige el MANAGER. Vacío: la app le asigna uno por su cuenta.
    icon = models.CharField(max_length=16, blank=True, default="")
    # Las categorías no se borran: se desactivan.
    active = models.BooleanField(default=True)

    class Meta:
        ordering = ["name"]
        verbose_name_plural = "categories"

    def __str__(self) -> str:
        return self.name
