from decimal import Decimal
from unittest.mock import patch

import pytest
from django.core.cache import cache
from rest_framework.test import APIClient

from apps.auth.models import User
from apps.cash_sessions.models import CashSession
from apps.exchange_rate.models import ExchangeRate
from apps.exchange_rate.services import (
    bcv_rate_service,
    exchange_rate_service,
    pricing_settings_service,
)
from apps.sales.domain.dtos import CreateSaleInput, PaymentInput, SaleItemInput
from apps.sales.services import sale_service, sales_report_service
from core.enums import Currency, PaymentMethod, RateMode, RateSource
from core.exceptions import DomainError, PaymentMismatchError
from tests.factories import (
    BranchInventoryFactory,
    CashSessionFactory,
    ExchangeRateFactory,
    ProductFactory,
)
from tests.integration.test_bcv_rate import BCV_RATE, NEXT_BCV_RATE

pytestmark = pytest.mark.django_db

SETTINGS_URL = "/api/v1/pricing-settings/"


@pytest.fixture(autouse=True)
def clean_cache() -> None:
    cache.clear()
    yield
    cache.clear()


def _patch_fetch(**kwargs: object):
    return patch.object(bcv_rate_service, "_fetch_bcv_rate", **kwargs)


def test_defaults_follow_the_bcv_without_rounding() -> None:
    settings = pricing_settings_service.get_settings()

    assert (settings.rate_mode, settings.round_ves_up) == (RateMode.BCV, False)


def test_own_rate_is_not_replaced_by_the_bcv(manager: User) -> None:
    with _patch_fetch(return_value=BCV_RATE):
        bcv_rate_service.sync_active_rate()
    pricing_settings_service.update_settings(rate_mode=RateMode.MANUAL)
    own = exchange_rate_service.register_rate(usd_to_ves_rate=Decimal("900"), user=manager)

    # El BCV publica una tasa nueva, pero el negocio vende con la suya.
    with _patch_fetch(return_value=NEXT_BCV_RATE) as fetch:
        assert bcv_rate_service.sync_active_rate() is None

    assert not fetch.called
    assert exchange_rate_service.get_active_rate() == own
    assert ExchangeRate.objects.count() == 2


def test_going_back_to_the_bcv_activates_its_rate_at_once(manager: User) -> None:
    with _patch_fetch(return_value=BCV_RATE):
        bcv_rate_service.sync_active_rate()
    pricing_settings_service.update_settings(rate_mode=RateMode.MANUAL)
    exchange_rate_service.register_rate(usd_to_ves_rate=Decimal("900"), user=manager)

    # El BCV no cambió desde la última sincronización, pero la activa es la manual.
    with _patch_fetch(return_value=BCV_RATE):
        settings = pricing_settings_service.update_settings(rate_mode=RateMode.BCV)

    active = exchange_rate_service.get_active_rate()
    assert settings.rate_mode == RateMode.BCV
    assert (active.source, active.usd_to_ves_rate) == (RateSource.BCV, BCV_RATE.rate)


def test_going_back_to_the_bcv_fails_whole_if_it_cannot_be_reached() -> None:
    pricing_settings_service.update_settings(rate_mode=RateMode.MANUAL)

    with _patch_fetch(side_effect=ValueError("sin respuesta")), pytest.raises(DomainError) as exc:
        pricing_settings_service.update_settings(rate_mode=RateMode.BCV)

    assert exc.value.code == "bcv_rate_unavailable"
    assert pricing_settings_service.get_settings().rate_mode == RateMode.MANUAL


def test_unknown_fields_are_rejected() -> None:
    with pytest.raises(ValueError):
        pricing_settings_service.update_settings(id=2)


def test_manager_changes_settings_through_api(api_client: APIClient, manager: User) -> None:
    api_client.force_authenticate(manager)

    assert api_client.get(SETTINGS_URL).data == {"rate_mode": "BCV", "round_ves_up": False}
    patched = api_client.patch(
        SETTINGS_URL, {"rate_mode": "MANUAL", "round_ves_up": True}, format="json"
    )

    assert patched.status_code == 200
    assert patched.data == {"rate_mode": "MANUAL", "round_ves_up": True}
    assert api_client.patch(SETTINGS_URL, {"rate_mode": "X"}, format="json").status_code == 400


def test_supervisor_reads_but_cannot_change_settings(
    api_client: APIClient, supervisor: User
) -> None:
    api_client.force_authenticate(supervisor)

    assert api_client.get(SETTINGS_URL).status_code == 200
    assert api_client.patch(SETTINGS_URL, {"round_ves_up": True}, format="json").status_code == 403


# --- Ventas con los bolívares redondeados hacia arriba -----------------------


@pytest.fixture
def session(supervisor: User) -> CashSession:
    """Caja abierta del supervisor, con una tasa que deja céntimos en los precios."""
    ExchangeRateFactory(usd_to_ves_rate=Decimal("150.3000"))
    return CashSessionFactory(user=supervisor)


def _broom() -> int:
    product = ProductFactory(
        name="Broom", cost_price_usd=Decimal("3.00"), sale_price_usd=Decimal("4.50")
    )
    BranchInventoryFactory(product=product, current_stock=Decimal("10.000"))
    return product.pk


def _sale(product_id: int, quantity: str, payments: list[PaymentInput]) -> CreateSaleInput:
    return CreateSaleInput(
        items=(SaleItemInput(product_id, Decimal(quantity)),), payments=tuple(payments)
    )


def _ves(amount: str) -> PaymentInput:
    return PaymentInput(PaymentMethod.CASH_VES, Currency.VES, Decimal(amount))


def test_sale_with_rounding_charges_whole_bolivars(supervisor: User, session: CashSession) -> None:
    pricing_settings_service.update_settings(round_ves_up=True)
    broom = _broom()

    # 4,50 $ × 150,30 = 676,35 → 677 Bs cada una.
    sale = sale_service.create_sale(_sale(broom, "2", [_ves("1354.00")]), supervisor)

    assert (sale.total_usd, sale.total_ves) == (Decimal("9.00"), Decimal("1354.00"))
    assert sale.details.get().subtotal_ves == Decimal("1354.00")
    # La tasa de la venta sigue siendo la real.
    assert sale.exchange_rate_at_invoice == Decimal("150.3000")
    report = sales_report_service.build_session_report(session.pk)
    assert (report.total_ves, report.products[0].sales_ves) == (
        Decimal("1354.00"),
        Decimal("1354.00"),
    )
    # El costo no se redondea: 6,00 $ × 150,30.
    assert (report.cost_ves, report.profit_ves) == (Decimal("901.80"), Decimal("452.20"))


def test_sale_with_rounding_rejects_the_unrounded_amount(
    supervisor: User, session: CashSession
) -> None:
    pricing_settings_service.update_settings(round_ves_up=True)
    broom = _broom()

    # 1.352,70 Bs es el total sin redondear: faltan 1,30 Bs, menos que la tolerancia de
    # 0,01 $ (1,50 Bs), así que se acepta; con 1.350 Bs ya no.
    with pytest.raises(PaymentMismatchError):
        sale_service.create_sale(_sale(broom, "2", [_ves("1350.00")]), supervisor)


def test_sale_without_rounding_keeps_the_cents(supervisor: User, session: CashSession) -> None:
    broom = _broom()

    sale = sale_service.create_sale(_sale(broom, "2", [_ves("1352.70")]), supervisor)

    assert sale.total_ves == Decimal("1352.70")
    assert sale.details.get().subtotal_ves == Decimal("1352.70")
