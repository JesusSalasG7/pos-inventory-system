from decimal import Decimal

import factory

from apps.inventory.models import BranchInventory, Product
from core.enums import ProductCategory, UnitOfMeasure

from .branches import VILLA_LIBERTAD, BranchCodeMixin


class ProductFactory(factory.django.DjangoModelFactory):
    class Meta:
        model = Product

    name = factory.Sequence(lambda n: f"Product {n}")
    category = ProductCategory.LIQUIDS
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
