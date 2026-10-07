from decimal import Decimal

import factory

from apps.inventory.models import BranchInventory, Category, Product
from core.enums import UnitOfMeasure

from .branches import VILLA_LIBERTAD, BranchCodeMixin


class CategoryFactory(factory.django.DjangoModelFactory):
    class Meta:
        model = Category
        django_get_or_create = ("name",)

    # Por defecto todos los productos de los tests comparten esta categoría.
    name = "Líquidos"


class ProductFactory(factory.django.DjangoModelFactory):
    class Meta:
        model = Product

    name = factory.Sequence(lambda n: f"Product {n}")
    category = factory.SubFactory(CategoryFactory)
    unit_of_measure = UnitOfMeasure.LITER
    cost_price_usd = Decimal("1.00")
    sale_price_usd = Decimal("1.50")


class BranchInventoryFactory(BranchCodeMixin, factory.django.DjangoModelFactory):
    class Meta:
        model = BranchInventory

    product = factory.SubFactory(ProductFactory)
    branch = VILLA_LIBERTAD
    current_stock = Decimal("10.000")
    minimum_stock = Decimal("2.000")
