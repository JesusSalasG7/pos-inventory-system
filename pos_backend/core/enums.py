"""Enumeraciones de dominio compartidas por todas las apps."""

from django.db import models


class Role(models.TextChoices):
    MANAGER = "MANAGER", "Gerente"
    SUPERVISOR = "SUPERVISOR", "Supervisor"


class ProductCategory(models.TextChoices):
    # Ampliable: agregar aquí nuevas categorías y generar la migración.
    LIQUIDS = "LIQUIDS", "Líquidos"
    POWDERS = "POWDERS", "Polvos"
    ACCESSORIES = "ACCESSORIES", "Accesorios"


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


class Currency(models.TextChoices):
    VES = "VES", "Bolívares"
    USD = "USD", "Dólares"
