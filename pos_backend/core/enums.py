"""Enumeraciones de dominio compartidas por todas las apps."""

from django.db import models


class Role(models.TextChoices):
    MANAGER = "MANAGER", "Gerente"
    SUPERVISOR = "SUPERVISOR", "Supervisor"


class UnitOfMeasure(models.TextChoices):
    LITER = "LITER", "Litro"
    KILOGRAM = "KILOGRAM", "Kilogramo"
    UNIT = "UNIT", "Unidad"


class MovementType(models.TextChoices):
    ENTRY = "ENTRY", "Entrada"
    SALE = "SALE", "Venta"
    WASTE = "WASTE", "Merma"
    ADJUSTMENT = "ADJUSTMENT", "Ajuste"


class PaymentMethod(models.TextChoices):
    POS_CARD = "POS_CARD", "Punto de venta"
    CASH_VES = "CASH_VES", "Efectivo VES"
    CASH_USD = "CASH_USD", "Efectivo USD"
    MOBILE_PAYMENT = "MOBILE_PAYMENT", "Pago móvil"


class RateSource(models.TextChoices):
    """Origen de una tasa de cambio registrada."""

    MANUAL = "MANUAL", "Manual"
    BCV = "BCV", "BCV"


class RateMode(models.TextChoices):
    """Con qué tasa se calculan los bolívares del negocio."""

    # La tasa activa sigue sola a la del BCV.
    BCV = "BCV", "BCV automática"
    # La tasa activa es la que fija un MANAGER; el BCV no la reemplaza.
    MANUAL = "MANUAL", "Tasa propia"


class Currency(models.TextChoices):
    VES = "VES", "Bolívares"
    USD = "USD", "Dólares"
