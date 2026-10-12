"""Subcategorías del catálogo: el segundo nivel, dentro de una categoría."""

from django.db import models

from core.models import TimeStampedModel


class Subcategory(TimeStampedModel):
    # Una subcategoría no cambia de categoría: sus productos quedarían fuera de la suya.
    category = models.ForeignKey(
        "inventory.Category", on_delete=models.PROTECT, related_name="subcategories"
    )
    name = models.CharField(max_length=100)
    # Las subcategorías no se borran: se desactivan.
    active = models.BooleanField(default=True)

    class Meta:
        ordering = ["name"]
        verbose_name_plural = "subcategories"
        constraints = [
            models.UniqueConstraint(
                fields=["category", "name"], name="unique_subcategory_category_name"
            ),
        ]

    def __str__(self) -> str:
        return self.name
