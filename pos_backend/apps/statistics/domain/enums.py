"""Enumeraciones propias de las estadísticas."""

from django.db import models


class GroupLevel(models.TextChoices):
    """Nivel que devuelve el rendimiento por grupo."""

    CATEGORY = "category", "Categoría"
    SUBCATEGORY = "subcategory", "Subcategoría"


class RankingOrder(models.TextChoices):
    """Métrica por la que se ordena el ranking de productos."""

    UNITS = "units", "Unidades"
    REVENUE = "revenue", "Ingresos"
    PROFIT = "profit", "Ganancia"
    MARGIN = "margin", "Margen"


class Quadrant(models.TextChoices):
    """Cuadrante de la matriz volumen vs. margen, con cortes en las medianas."""

    STAR = "STAR", "Estrella"
    VOLUME_DRIVER = "VOLUME_DRIVER", "Motor de volumen"
    PROFITABLE_NICHE = "PROFITABLE_NICHE", "Nicho rentable"
    REVIEW = "REVIEW", "Revisar"
