"""Modelos base abstractos."""

from django.db import models


class TimeStampedModel(models.Model):
    """Agrega marcas de creación y última modificación."""

    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        abstract = True
