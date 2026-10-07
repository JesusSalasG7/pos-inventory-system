from datetime import datetime
from decimal import Decimal
from unittest.mock import patch

import pytest
from rest_framework.test import APIClient

from apps.auth.models import User
from apps.cash_sessions.models import CashSession
from apps.exchange_rate.domain.dtos import BcvRate
from apps.exchange_rate.services import bcv_rate_service, pricing_settings_service
from apps.inventory.services import product_service
from apps.sales.domain.dtos import CreateSaleInput, PaymentInput, SaleItemInput
from apps.sales.models import Sale, SaleDetail
from apps.sales.services import sale_service, sales_report_service
from core.enums import Currency, PaymentMethod, RateMode, RateSource
from tests.factories import (
    LAS_AMERICAS,
    BranchInventoryFactory,
    CashSessionFactory,
    ExchangeRateFactory,
    ProductFactory,
    UserFactory,
)

pytestmark = pytest.mark.django_db


@pytest.fixture
def session(supervisor: User) -> CashSession:
    """Caja abierta del supervisor en VILLA_LIBERTAD, con tasa 150 registrada."""
    ExchangeRateFactory(usd_to_ves_rate=Decimal("150.0000"))
    return CashSessionFactory(user=supervisor)


def stocked(name: str, cost: str, price: str) -> int:
    product = ProductFactory(name=name, cost_price_usd=Decimal(cost), sale_price_usd=Decimal(price))
    BranchInventoryFactory(product=product, current_stock=Decimal("50.000"))
    return product.pk


def sell(user: User, items: dict[int, str], payments: list[PaymentInput]) -> None:
    sale_service.create_sale(
        CreateSaleInput(
            items=tuple(SaleItemInput(pk, Decimal(qty)) for pk, qty in items.items()),
            payments=tuple(payments),
        ),
        user,
    )


def cash_usd(amount: str) -> PaymentInput:
    return PaymentInput(PaymentMethod.CASH_USD, Currency.USD, Decimal(amount))


def mobile(amount: str) -> PaymentInput:
    return PaymentInput(PaymentMethod.MOBILE_PAYMENT, Currency.VES, Decimal(amount), "REF-1")


def test_sale_freezes_the_product_cost(supervisor: User, session: CashSession) -> None:
    bleach = stocked("Bleach", cost="0.80", price="1.20")

    sell(supervisor, {bleach: "2"}, [cash_usd("2.40")])
    product_service.update_product(bleach, cost_price_usd=Decimal("5.00"))

    assert SaleDetail.objects.get().unit_cost_usd == Decimal("0.80")
    report = sales_report_service.build_session_report(session.pk)
    assert report.cost_usd == Decimal("1.60")
    assert report.profit_usd == Decimal("0.80")


def test_report_totals_payments_cost_and_profit(supervisor: User, session: CashSession) -> None:
    bleach = stocked("Bleach", cost="0.80", price="1.20")
    broom = stocked("Broom", cost="3.00", price="4.50")

    # Venta 1 a tasa 150: 2,5 × 1,20 + 1 × 4,50 = 7,50 $ (1.125,00 Bs).
    sell(supervisor, {bleach: "2.5", broom: "1"}, [cash_usd("3.00"), mobile("675.00")])
    # Venta 2 a tasa 200: 1 × 4,50 = 4,50 $ (900,00 Bs).
    ExchangeRateFactory(usd_to_ves_rate=Decimal("200.0000"))
    sell(supervisor, {broom: "1"}, [mobile("900.00")])

    report = sales_report_service.build_session_report(session.pk)

    assert (report.sales_count, report.total_usd, report.total_ves) == (
        2,
        Decimal("12.00"),
        Decimal("2025.00"),
    )
    # Costo: 2,5 × 0,80 + 1 × 3,00 = 5,00 $ a 150, más 3,00 $ a 200.
    assert (report.cost_usd, report.cost_ves) == (Decimal("8.00"), Decimal("1350.00"))
    assert (report.profit_usd, report.profit_ves) == (Decimal("4.00"), Decimal("675.00"))
    assert [(p.method, p.currency, p.amount) for p in report.payments] == [
        (PaymentMethod.CASH_USD, Currency.USD, Decimal("3.00")),
        (PaymentMethod.MOBILE_PAYMENT, Currency.VES, Decimal("1575.00")),
    ]
    # Primero el producto que más vendió.
    assert [p.product_name for p in report.products] == ["Broom", "Bleach"]
    top = report.products[0]
    assert (top.quantity, top.sales_usd, top.sales_ves) == (
        Decimal("2.000"),
        Decimal("9.00"),
        Decimal("1575.00"),
    )
    assert (top.cost_usd, top.cost_ves, top.profit_usd, top.profit_ves) == (
        Decimal("6.00"),
        Decimal("1050.00"),
        Decimal("3.00"),
        Decimal("525.00"),
    )


def test_cost_in_ves_uses_the_bcv_rate_when_selling_with_an_own_rate(
    supervisor: User, session: CashSession
) -> None:
    pricing_settings_service.update_settings(rate_mode=RateMode.MANUAL)
    ExchangeRateFactory(usd_to_ves_rate=Decimal("200.0000"))
    bleach = stocked("Bleach", cost="0.80", price="1.20")
    bcv = BcvRate(rate=Decimal("150.0000"), updated_at=datetime.fromisoformat("2026-10-06T00:00"))

    # Se cobra a la tasa propia (200) y el costo se valora con la del BCV (150).
    with patch.object(bcv_rate_service, "_fetch_bcv_rate", return_value=bcv):
        sell(supervisor, {bleach: "2"}, [mobile("480.00")])

    sale = Sale.objects.get()
    assert (sale.exchange_rate_at_invoice, sale.bcv_rate_at_invoice) == (
        Decimal("200.0000"),
        Decimal("150.0000"),
    )
    report = sales_report_service.build_session_report(session.pk)
    assert (report.total_ves, report.cost_ves, report.profit_ves) == (
        Decimal("480.00"),
        Decimal("240.00"),
        Decimal("240.00"),
    )
    assert (report.cost_usd, report.profit_usd) == (Decimal("1.60"), Decimal("0.80"))


def test_cost_in_ves_ignores_a_manual_rate_set_over_the_bcv_one(
    supervisor: User, session: CashSession
) -> None:
    ExchangeRateFactory(usd_to_ves_rate=Decimal("160.0000"), source=RateSource.BCV, created_by=None)
    ExchangeRateFactory(usd_to_ves_rate=Decimal("200.0000"))
    bleach = stocked("Bleach", cost="0.80", price="1.20")

    sell(supervisor, {bleach: "2"}, [mobile("480.00")])

    report = sales_report_service.build_session_report(session.pk)
    assert (report.cost_ves, report.profit_ves) == (Decimal("256.00"), Decimal("224.00"))


def test_cost_in_ves_keeps_the_bcv_rate_of_the_sale(supervisor: User, session: CashSession) -> None:
    ExchangeRateFactory(usd_to_ves_rate=Decimal("160.0000"), source=RateSource.BCV, created_by=None)
    bleach = stocked("Bleach", cost="0.80", price="1.20")
    sell(supervisor, {bleach: "2"}, [mobile("384.00")])

    # El BCV publica otra tasa después: la venta ya hecha no cambia.
    ExchangeRateFactory(usd_to_ves_rate=Decimal("180.0000"), source=RateSource.BCV, created_by=None)

    assert sales_report_service.build_session_report(session.pk).cost_ves == Decimal("256.00")


def test_cost_in_ves_falls_back_to_the_sale_rate_without_a_bcv_rate(
    supervisor: User, session: CashSession
) -> None:
    bleach = stocked("Bleach", cost="0.80", price="1.20")

    # Sin tasa del BCV registrada y con el BCV caído, la venta no se bloquea.
    sell(supervisor, {bleach: "2"}, [cash_usd("2.40")])

    assert Sale.objects.get().bcv_rate_at_invoice == Decimal("150.0000")
    assert sales_report_service.build_session_report(session.pk).cost_ves == Decimal("240.00")


def test_report_of_a_session_without_sales(session: CashSession) -> None:
    report = sales_report_service.build_session_report(session.pk)

    assert (report.sales_count, report.total_usd, report.cost_ves, report.profit_usd) == (
        0,
        Decimal("0.00"),
        Decimal("0.00"),
        Decimal("0.00"),
    )
    assert report.payments == ()
    assert report.products == ()


def test_report_only_counts_its_own_session(supervisor: User, session: CashSession) -> None:
    bleach = stocked("Bleach", cost="0.80", price="1.20")
    sell(supervisor, {bleach: "1"}, [cash_usd("1.20")])
    other = CashSessionFactory(user=UserFactory(assigned_branch=LAS_AMERICAS), branch=LAS_AMERICAS)

    assert sales_report_service.build_session_report(other.pk).sales_count == 0
    assert sales_report_service.build_session_report(session.pk).sales_count == 1


def test_sales_report_through_api(
    api_client: APIClient, supervisor: User, session: CashSession
) -> None:
    bleach = stocked("Bleach", cost="0.80", price="1.20")
    sell(supervisor, {bleach: "2"}, [cash_usd("2.40")])
    api_client.force_authenticate(supervisor)

    response = api_client.get(f"/api/v1/cash-sessions/{session.pk}/sales-report/")

    assert response.status_code == 200
    assert response.data["total_usd"] == "2.40"
    assert response.data["cost_ves"] == "240.00"
    assert response.data["profit_usd"] == "0.80"
    assert response.data["payments"] == [
        {"method": "CASH_USD", "currency": "USD", "amount": "2.40"}
    ]
    assert response.data["products"][0]["product"] == bleach
    assert response.data["products"][0]["quantity"] == "2.000"


def test_supervisor_cannot_read_the_report_of_another_branch(
    api_client: APIClient, supervisor: User, session: CashSession
) -> None:
    other = CashSessionFactory(user=UserFactory(assigned_branch=LAS_AMERICAS), branch=LAS_AMERICAS)
    api_client.force_authenticate(supervisor)

    response = api_client.get(f"/api/v1/cash-sessions/{other.pk}/sales-report/")

    assert response.status_code in (403, 404)
