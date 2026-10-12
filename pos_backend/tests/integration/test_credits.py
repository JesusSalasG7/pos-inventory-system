from datetime import timedelta
from decimal import Decimal

import pytest
from django.utils import timezone
from rest_framework.test import APIClient

from apps.auth.models import User
from apps.cash_sessions.models import CashSession
from apps.cash_sessions.services import cash_count_service
from apps.credits.domain.dtos import CreditPaymentInput
from apps.credits.models import Credit, CreditPayment, Customer
from apps.credits.services import credit_service
from apps.inventory.models import BranchInventory
from apps.sales.domain.dtos import CreateSaleInput, PaymentInput, SaleItemInput
from apps.sales.models import Sale
from apps.sales.services import sale_service, sales_report_service
from core.enums import Currency, PaymentMethod, RateSource
from core.exceptions import DomainError, NoOpenSessionError
from tests.factories import (
    LAS_AMERICAS,
    BranchInventoryFactory,
    CashSessionFactory,
    CustomerFactory,
    ExchangeRateFactory,
    ProductFactory,
    UserFactory,
)

pytestmark = pytest.mark.django_db

CUSTOMERS_URL = "/api/v1/customers/"
CREDITS_URL = "/api/v1/credits/"


@pytest.fixture
def session(supervisor: User) -> CashSession:
    """Caja abierta del supervisor en VILLA_LIBERTAD.

    La tasa del BCV registrada es 150 y la activa, una manual de 200: los
    abonos en bolívares deben convertirse con la del BCV.
    """
    ExchangeRateFactory(usd_to_ves_rate=Decimal("150.0000"), source=RateSource.BCV)
    ExchangeRateFactory(usd_to_ves_rate=Decimal("200.0000"))
    return CashSessionFactory(user=supervisor)


@pytest.fixture
def customer() -> Customer:
    return CustomerFactory(name="Ana Pérez", tax_id="V-123", credit_days=7)


def stocked(price: str) -> BranchInventory:
    return BranchInventoryFactory(
        product=ProductFactory(sale_price_usd=Decimal(price)), current_stock=Decimal("10.000")
    )


def credit(amount: str) -> PaymentInput:
    return PaymentInput(PaymentMethod.CREDIT, Currency.USD, Decimal(amount))


def cash_usd(amount: str) -> PaymentInput:
    return PaymentInput(PaymentMethod.CASH_USD, Currency.USD, Decimal(amount))


def sell_on_credit(
    user: User, customer: Customer | None, price: str, payments: list[PaymentInput], **kwargs
) -> Sale:
    inventory = stocked(price)
    return sale_service.create_sale(
        CreateSaleInput(
            items=(SaleItemInput(inventory.product_id, Decimal("1")),),
            payments=tuple(payments),
            customer_id=customer.pk if customer else None,
            **kwargs,
        ),
        user,
    )


def pay(user: User, customer: Customer, method: PaymentMethod, amount: str, ref: str = ""):
    currency = Currency.USD if method == PaymentMethod.CASH_USD else Currency.VES
    return credit_service.register_payment(
        CreditPaymentInput(customer.pk, method, currency, Decimal(amount), ref), user
    )


# --- Venta a crédito ----------------------------------------------------------


def test_credit_sale_opens_a_debt_in_usd(
    supervisor: User, session: CashSession, customer: Customer
) -> None:
    sale = sell_on_credit(supervisor, customer, "12.00", [credit("12.00")])

    debt = Credit.objects.get(sale=sale)
    assert debt.customer == customer
    assert debt.branch_id == session.branch_id
    assert (debt.amount_usd, debt.balance_usd) == (Decimal("12.00"), Decimal("12.00"))
    assert debt.due_date == timezone.localdate() + timedelta(days=7)
    assert debt.paid_at is None
    # El nombre y la cédula del cliente quedan en la venta.
    assert (sale.customer_name, sale.customer_tax_id) == ("Ana Pérez", "V-123")
    assert sale.payments.get().method == PaymentMethod.CREDIT


def test_credit_sale_with_down_payment_and_custom_term(
    supervisor: User, session: CashSession, customer: Customer
) -> None:
    sale = sell_on_credit(
        supervisor, customer, "10.00", [cash_usd("4.00"), credit("6.00")], credit_days=0
    )

    debt = sale.credit
    assert debt.amount_usd == Decimal("6.00")
    assert debt.due_date == timezone.localdate()


def test_credit_sale_requires_a_customer(supervisor: User, session: CashSession) -> None:
    with pytest.raises(DomainError) as error:
        sell_on_credit(supervisor, None, "5.00", [credit("5.00")])

    assert error.value.code == "customer_required"
    assert not Sale.objects.exists()


def test_credit_sale_rejects_an_inactive_customer(
    supervisor: User, session: CashSession, customer: Customer
) -> None:
    customer.active = False
    customer.save()

    with pytest.raises(DomainError) as error:
        sell_on_credit(supervisor, customer, "5.00", [credit("5.00")])

    assert error.value.code == "inactive_customer"
    assert not Credit.objects.exists()


def test_credit_sale_admits_a_single_credit_payment(
    supervisor: User, session: CashSession, customer: Customer
) -> None:
    with pytest.raises(DomainError) as error:
        sell_on_credit(supervisor, customer, "5.00", [credit("2.00"), credit("3.00")])

    assert error.value.code == "invalid_payment"


# --- Abonos -------------------------------------------------------------------


def test_payment_in_usd_is_applied_to_the_oldest_debt_first(
    supervisor: User, session: CashSession, customer: Customer
) -> None:
    first = sell_on_credit(supervisor, customer, "5.00", [credit("5.00")], credit_days=3).credit
    second = sell_on_credit(supervisor, customer, "8.00", [credit("8.00")], credit_days=10).credit

    payment = pay(supervisor, customer, PaymentMethod.CASH_USD, "7.00")

    first.refresh_from_db()
    second.refresh_from_db()
    assert (first.balance_usd, second.balance_usd) == (Decimal("0.00"), Decimal("6.00"))
    assert first.paid_at is not None and second.paid_at is None
    assert payment.amount_usd == Decimal("7.00")
    assert payment.cash_session == session
    assert [(a.credit_id, a.amount_usd) for a in payment.allocations.order_by("id")] == [
        (first.pk, Decimal("5.00")),
        (second.pk, Decimal("2.00")),
    ]


@pytest.mark.parametrize("method", [PaymentMethod.MOBILE_PAYMENT, PaymentMethod.POS_CARD])
def test_payment_reference_is_optional(
    method: PaymentMethod, supervisor: User, session: CashSession, customer: Customer
) -> None:
    sell_on_credit(supervisor, customer, "20.00", [credit("20.00")])

    payment = pay(supervisor, customer, method, "1500.00", "   ")

    assert payment.approval_reference == ""


def test_payment_in_bolivars_uses_the_bcv_rate_not_the_active_one(
    supervisor: User, session: CashSession, customer: Customer
) -> None:
    debt = sell_on_credit(supervisor, customer, "20.00", [credit("20.00")]).credit

    # 1.500 Bs a la tasa del BCV (150) son 10 USD; con la manual (200) serían 7,50.
    payment = pay(supervisor, customer, PaymentMethod.MOBILE_PAYMENT, "1500.00", "REF-7")

    debt.refresh_from_db()
    assert payment.usd_to_ves_rate == Decimal("150.0000")
    assert payment.amount_usd == Decimal("10.00")
    assert debt.balance_usd == Decimal("10.00")


def test_payment_in_bolivars_within_tolerance_settles_the_debt(
    supervisor: User, session: CashSession, customer: Customer
) -> None:
    ExchangeRateFactory(usd_to_ves_rate=Decimal("873.8700"), source=RateSource.BCV)
    debt = sell_on_credit(supervisor, customer, "3.33", [credit("3.33")]).credit

    # 3,33 × 873,87 = 2.909,99 Bs → 3,329.. USD: el redondeo no deja céntimos pendientes.
    payment = pay(supervisor, customer, PaymentMethod.CASH_VES, "2909.99")

    debt.refresh_from_db()
    assert payment.amount_usd == Decimal("3.33")
    assert debt.balance_usd == Decimal("0.00")
    assert debt.paid_at is not None


def test_overpayment_is_rejected(
    supervisor: User, session: CashSession, customer: Customer
) -> None:
    sell_on_credit(supervisor, customer, "5.00", [credit("5.00")])

    with pytest.raises(DomainError) as error:
        pay(supervisor, customer, PaymentMethod.CASH_USD, "6.00")

    assert error.value.code == "credit_overpayment"
    assert error.value.meta["balance_usd"] == "5.00"
    assert error.value.meta["balance_ves"] == "750.00"
    assert not CreditPayment.objects.exists()


def test_payment_without_debt_is_rejected(
    supervisor: User, session: CashSession, customer: Customer
) -> None:
    with pytest.raises(DomainError) as error:
        pay(supervisor, customer, PaymentMethod.CASH_USD, "1.00")

    assert error.value.code == "no_pending_credit"


def test_payment_cannot_be_on_credit(
    supervisor: User, session: CashSession, customer: Customer
) -> None:
    sell_on_credit(supervisor, customer, "5.00", [credit("5.00")])

    with pytest.raises(DomainError) as error:
        credit_service.register_payment(
            CreditPaymentInput(customer.pk, PaymentMethod.CREDIT, Currency.USD, Decimal("1")),
            supervisor,
        )

    assert error.value.code == "invalid_payment"


def test_payment_requires_an_open_session(
    supervisor: User, session: CashSession, customer: Customer
) -> None:
    sell_on_credit(supervisor, customer, "5.00", [credit("5.00")])
    other = UserFactory()

    with pytest.raises(NoOpenSessionError):
        pay(other, customer, PaymentMethod.CASH_USD, "1.00")


def test_payment_only_covers_debts_of_the_session_branch(
    supervisor: User, session: CashSession, customer: Customer
) -> None:
    sell_on_credit(supervisor, customer, "5.00", [credit("5.00")])
    other = UserFactory(assigned_branch=LAS_AMERICAS)
    CashSessionFactory(user=other, branch=LAS_AMERICAS)

    with pytest.raises(DomainError) as error:
        pay(other, customer, PaymentMethod.CASH_USD, "1.00")

    assert error.value.code == "no_pending_credit"


# --- Arqueo y resumen de la caja ----------------------------------------------


def test_cash_count_ignores_credit_and_adds_cash_payments(
    supervisor: User, session: CashSession, customer: Customer
) -> None:
    sell_on_credit(supervisor, customer, "10.00", [cash_usd("4.00"), credit("6.00")])
    pay(supervisor, customer, PaymentMethod.CASH_USD, "2.00")
    pay(supervisor, customer, PaymentMethod.CASH_VES, "150.00")
    pay(supervisor, customer, PaymentMethod.MOBILE_PAYMENT, "150.00", "REF-1")

    summary = cash_count_service.build_summary(session)

    assert summary.cash_sales_usd == Decimal("4.00")
    assert summary.electronic_sales_usd == Decimal("0.00")
    assert summary.credit_cash_usd == Decimal("2.00")
    assert summary.credit_cash_ves == Decimal("150.00")
    assert summary.credit_electronic_ves == Decimal("150.00")
    # Fondo 20 + venta 4 + abono 2.
    assert summary.expected_cash_usd == Decimal("26.00")
    assert summary.expected_cash_ves == Decimal("150.00")


def test_session_report_lists_credit_sales_and_collections(
    supervisor: User, session: CashSession, customer: Customer
) -> None:
    sell_on_credit(supervisor, customer, "10.00", [cash_usd("4.00"), credit("6.00")])
    pay(supervisor, customer, PaymentMethod.CASH_USD, "2.00")

    report = sales_report_service.build_session_report(session.pk)

    assert report.total_usd == Decimal("10.00")
    assert {(p.method, p.amount) for p in report.payments} == {
        (PaymentMethod.CASH_USD, Decimal("4.00")),
        (PaymentMethod.CREDIT, Decimal("6.00")),
    }
    assert [(p.method, p.amount) for p in report.credit_collections] == [
        (PaymentMethod.CASH_USD, Decimal("2.00"))
    ]


# --- API ----------------------------------------------------------------------


def test_api_credit_sale_and_payment_flow(
    api_client: APIClient, supervisor: User, session: CashSession
) -> None:
    api_client.force_authenticate(supervisor)
    inventory = stocked("10.00")

    created = api_client.post(
        CUSTOMERS_URL, {"name": " Luis ", "tax_id": "v-9", "credit_days": 15}, format="json"
    )
    assert created.status_code == 201
    customer_id = created.data["id"]
    assert (created.data["name"], created.data["tax_id"]) == ("Luis", "V-9")

    sale = api_client.post(
        "/api/v1/sales/",
        {
            "customer_id": customer_id,
            "items": [{"product_id": inventory.product_id, "quantity": "1"}],
            "payments": [{"method": "CREDIT", "currency": "USD", "amount": "10.00"}],
        },
        format="json",
    )
    assert sale.status_code == 201, sale.data
    assert sale.data["customer"] == customer_id
    assert sale.data["credit_due_date"] == str(timezone.localdate() + timedelta(days=15))

    detail = api_client.get(f"{CUSTOMERS_URL}{customer_id}/")
    assert detail.data["balance_usd"] == "10.00"
    assert detail.data["payment_rate"] == "150.0000"
    assert detail.data["balance_ves"] == "1500.00"
    assert detail.data["open_credits"] == 1

    paid = api_client.post(
        f"{CUSTOMERS_URL}{customer_id}/payments/",
        {"method": "CASH_VES", "currency": "VES", "amount": "1500.00"},
        format="json",
    )
    assert paid.status_code == 201, paid.data
    assert paid.data["amount_usd"] == "10.00"

    assert api_client.get(f"{CUSTOMERS_URL}{customer_id}/").data["balance_usd"] == "0.00"
    assert api_client.get(f"{CUSTOMERS_URL}{customer_id}/payments/").data["count"] == 1
    assert api_client.get(CREDITS_URL, {"status": "PAID"}).data["count"] == 1
    assert api_client.get(CREDITS_URL).data["count"] == 0


def test_api_lists_overdue_credits_and_debtors(
    api_client: APIClient, supervisor: User, session: CashSession, customer: Customer
) -> None:
    api_client.force_authenticate(supervisor)
    sale = sell_on_credit(supervisor, customer, "5.00", [credit("5.00")])
    Credit.objects.filter(sale=sale).update(due_date=timezone.localdate() - timedelta(days=2))
    sell_on_credit(supervisor, customer, "3.00", [credit("3.00")])
    CustomerFactory(name="Sin deuda")

    overdue = api_client.get(CREDITS_URL, {"status": "OVERDUE"})
    assert overdue.data["count"] == 1
    assert overdue.data["results"][0]["is_overdue"] is True
    assert overdue.data["results"][0]["customer_name"] == "Ana Pérez"

    debtors = api_client.get(CUSTOMERS_URL, {"with_debt": "true"}).data["results"]
    assert [(c["name"], c["balance_usd"], c["overdue_usd"]) for c in debtors] == [
        ("Ana Pérez", "8.00", "5.00")
    ]


def test_api_customer_tax_id_is_unique(
    api_client: APIClient, supervisor: User, customer: Customer
) -> None:
    api_client.force_authenticate(supervisor)

    response = api_client.post(CUSTOMERS_URL, {"name": "Otra", "tax_id": "v-123"}, format="json")

    assert response.status_code == 409
    assert response.data["code"] == "customer_tax_id_taken"


def test_supervisor_does_not_see_debts_of_another_branch(
    api_client: APIClient, supervisor: User, session: CashSession, customer: Customer
) -> None:
    sell_on_credit(supervisor, customer, "5.00", [credit("5.00")])
    other = UserFactory(assigned_branch=LAS_AMERICAS)
    api_client.force_authenticate(other)

    assert api_client.get(CREDITS_URL).data["count"] == 0
    detail = api_client.get(f"{CUSTOMERS_URL}{customer.pk}/")
    assert detail.data["balance_usd"] == "0.00"
