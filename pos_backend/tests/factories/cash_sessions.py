from decimal import Decimal

import factory

from apps.cash_sessions.models import CashSession

from .branches import VILLA_LIBERTAD, BranchCodeMixin
from .users import UserFactory


class CashSessionFactory(BranchCodeMixin, factory.django.DjangoModelFactory):
    class Meta:
        model = CashSession

    user = factory.SubFactory(UserFactory)
    branch = VILLA_LIBERTAD
    opening_float = Decimal("20.00")
