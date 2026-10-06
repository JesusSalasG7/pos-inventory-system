from decimal import Decimal

import factory

from apps.exchange_rate.models import ExchangeRate

from .users import UserFactory


class ExchangeRateFactory(factory.django.DjangoModelFactory):
    class Meta:
        model = ExchangeRate

    usd_to_ves_rate = Decimal("150.0000")
    created_by = factory.SubFactory(UserFactory)
