from decimal import Decimal

import factory

from apps.sales.models import Sale, SalePayment
from core.enums import Currency, PaymentMethod

from .cash_sessions import CashSessionFactory


class SaleFactory(factory.django.DjangoModelFactory):
    class Meta:
        model = Sale

    cash_session = factory.SubFactory(CashSessionFactory)
    user = factory.SelfAttribute("cash_session.user")
    branch = factory.SelfAttribute("cash_session.branch")
    exchange_rate_at_invoice = Decimal("150.0000")
    total_usd = Decimal("10.00")
    total_ves = Decimal("1500.00")


class SalePaymentFactory(factory.django.DjangoModelFactory):
    class Meta:
        model = SalePayment

    sale = factory.SubFactory(SaleFactory)
    method = PaymentMethod.CASH_USD
    currency = Currency.USD
    amount = Decimal("10.00")
