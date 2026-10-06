from decimal import Decimal

import pytest
from django.db import IntegrityError, transaction
from django.utils import timezone

from tests.factories import (
    LAS_AMERICAS,
    VILLA_LIBERTAD,
    BranchInventoryFactory,
    CashSessionFactory,
    UserFactory,
)

pytestmark = pytest.mark.django_db


def test_user_cannot_have_two_open_cash_sessions() -> None:
    user = UserFactory()
    CashSessionFactory(user=user)

    with pytest.raises(IntegrityError), transaction.atomic():
        CashSessionFactory(user=user, branch=LAS_AMERICAS)


def test_user_can_open_a_new_session_after_closing_the_previous_one() -> None:
    user = UserFactory()
    CashSessionFactory(user=user, closed_at=timezone.now())

    CashSessionFactory(user=user)

    assert user.cash_sessions.count() == 2


def test_different_users_can_have_open_sessions_at_the_same_time() -> None:
    CashSessionFactory()
    CashSessionFactory()


def test_branch_inventory_is_unique_per_product_and_branch() -> None:
    inventory = BranchInventoryFactory()

    with pytest.raises(IntegrityError), transaction.atomic():
        BranchInventoryFactory(product=inventory.product, branch=inventory.branch)


def test_same_product_can_be_stocked_in_another_branch() -> None:
    inventory = BranchInventoryFactory(branch=VILLA_LIBERTAD)

    BranchInventoryFactory(product=inventory.product, branch=LAS_AMERICAS)

    assert inventory.product.branch_inventories.count() == 2


def test_current_stock_cannot_be_negative() -> None:
    with pytest.raises(IntegrityError), transaction.atomic():
        BranchInventoryFactory(current_stock=Decimal("-0.001"))
