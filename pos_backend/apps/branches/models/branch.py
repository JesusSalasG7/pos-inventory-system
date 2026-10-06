"""Sucursal física del negocio. Una instalación puede tener una o varias."""

from django.db import models

from core.models import TimeStampedModel


class Branch(TimeStampedModel):
    # Identificador estable: lo referencian las FK de las demás apps y nunca cambia.
    code = models.CharField(max_length=20, unique=True)
    name = models.CharField(max_length=100)
    # Las sucursales no se borran: se desactivan.
    active = models.BooleanField(default=True)

    class Meta:
        ordering = ["name"]
        verbose_name_plural = "branches"

    def __str__(self) -> str:
        return self.name
