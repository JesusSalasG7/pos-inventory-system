import threading
from datetime import timedelta
from decimal import Decimal

import pytest
from django.db import connection
from django.utils import timezone
from rest_framework.test import APIClient

from apps.auth.models import User
from apps.cash_sessions.models import CashSession
from apps.cash_sessions.services import cash_count_service, cash_session_service
from apps.inventory.models import BranchInventory, InventoryMovement
from apps.sales.domain.dtos import CreateSaleInput, PaymentInput, SaleItemInput
from apps.sales.models import Sale, SaleDetail, SalePayment
from apps.sales.services import sale_service
from core.enums import Currency, MovementType, PaymentMethod
from core.exceptions import (
    BranchAccessDeniedError,
    DomainError,
    InactiveProductError,
    InsufficientStockError,
    NoOpenSessionError,
    PaymentMismatchError,
)
from tests.factories import (
    LAS_AMERICAS,
    VILLA_LIBERTAD,
    BranchInventoryFactory,
    CashSessionFactory,
    ExchangeRateFactory,
    ProductFactory,
    SaleFactory,
    UserFactory,
)

pytestmark = pytest.mark.django_db

SALES_URL = "/api/v1/sales/"


def stocked(price: str, stock: str = "10.000", **kwargs: object) -> BranchInventory:
    return BranchInventoryFactory(
        product=ProductFactory(sale_price_usd=Decimal(price)),
        current_stock=Decimal(stock),
        **kwargs,
    )


def item(inventory: BranchInventory, quantity: str) -> SaleItemInput:
    return SaleItemInput(inventory.product_id, Decimal(quantity))


def cash_usd(amount: str) -> PaymentInput:
    return PaymentInput(PaymentMethod.CASH_USD, Currency.USD, Decimal(amount))


def mobile(amount: str, reference: str = "REF-1") -> PaymentInput:
    return PaymentInput(PaymentMethod.MOBILE_PAYMENT, Currency.VES, Decimal(amount), reference)


def sale_input(items: list, payments: list, **kwargs: object) -> CreateSaleInput:
    return CreateSaleInput(items=tuple(items), payments=tuple(payments), **kwargs)


def assert_nothing_persisted() -> None:
    assert not Sale.objects.exists()
    assert not SaleDetail.objects.exists()
    assert not SalePayment.objects.exists()
    assert not InventoryMovement.objects.exists()


@pytest.fixture
def session(supervisor: User) -> CashSession:
    """Caja abierta del supervisor en VILLA_LIBERTAD, con tasa 150 registrada."""
    ExchangeRateFactory(usd_to_ves_rate=Decimal("150.0000"))
    return CashSessionFactory(user=supervisor)


# --- Venta correcta ---------------------------------------------------------


def test_create_sale_with_mixed_payments(supervisor: User, session: CashSession) -> None:
    liquid = stocked("3.50")
    cloth = stocked("5.00", stock="3.000")

    sale = sale_service.create_sale(
        sale_input(
            [item(liquid, "2.5"), item(cloth, "1")],
            [cash_usd("10.00"), mobile("562.50", " REF-9 ")],
            customer_tax_id=" V-123 ",
            customer_name="Ana",
        ),
        supervisor,
    )

    assert sale.cash_session == session
    assert sale.user == supervisor
    assert sale.branch_id == VILLA_LIBERTAD
    assert sale.exchange_rate_at_invoice == Decimal("150.0000")
    assert (sale.total_usd, sale.total_ves) == (Decimal("13.75"), Decimal("2062.50"))
    assert (sale.customer_tax_id, sale.customer_name) == ("V-123", "Ana")

    details = {d.product_id: d for d in sale.details.all()}
    assert details[liquid.product_id].quantity == Decimal("2.500")
    assert details[liquid.product_id].unit_price_usd == Decimal("3.50")
    assert details[liquid.product_id].subtotal_usd == Decimal("8.75")
    assert details[cloth.product_id].subtotal_usd == Decimal("5.00")

    payments = {p.method: p for p in sale.payments.all()}
    assert payments[PaymentMethod.CASH_USD].amount == Decimal("10.00")
    assert payments[PaymentMethod.MOBILE_PAYMENT].approval_reference == "REF-9"

    liquid.refresh_from_db()
    cloth.refresh_from_db()
    assert (liquid.current_stock, cloth.current_stock) == (Decimal("7.500"), Decimal("2.000"))

    movement = InventoryMovement.objects.get(product=liquid.product)
    assert movement.movement_type == MovementType.SALE
    assert movement.sale == sale
    assert movement.user == supervisor
    assert (movement.quantity, movement.stock_before, movement.stock_after) == (
        Decimal("2.500"),
        Decimal("10.000"),
        Decimal("7.500"),
    )
    assert InventoryMovement.objects.count() == 2


def test_repeated_product_lines_are_merged(supervisor: User, session: CashSession) -> None:
    inventory = stocked("2.00")

    sale = sale_service.create_sale(
        sale_input([item(inventory, "1"), item(inventory, "1.5")], [cash_usd("5.00")]), supervisor
    )

    detail = sale.details.get()
    assert detail.quantity == Decimal("2.500")
    assert detail.subtotal_usd == Decimal("5.00")
    assert InventoryMovement.objects.count() == 1


def test_rate_and_price_are_frozen_in_the_sale(supervisor: User, session: CashSession) -> None:
    inventory = stocked("2.00")
    sale = sale_service.create_sale(
        sale_input([item(inventory, "1")], [cash_usd("2.00")]), supervisor
    )

    ExchangeRateFactory(usd_to_ves_rate=Decimal("200.0000"))
    inventory.product.sale_price_usd = Decimal("9.99")
    inventory.product.save()

    stored = sale_service.get_sale(sale.pk, supervisor)
    assert stored.exchange_rate_at_invoice == Decimal("150.0000")
    assert stored.total_ves == Decimal("300.00")
    assert stored.details.get().unit_price_usd == Decimal("2.00")


def test_selling_the_whole_stock_is_allowed(supervisor: User, session: CashSession) -> None:
    inventory = stocked("1.00", stock="4.000")

    sale_service.create_sale(sale_input([item(inventory, "4")], [cash_usd("4.00")]), supervisor)

    inventory.refresh_from_db()
    assert inventory.current_stock == Decimal("0.000")


def test_sale_feeds_the_cash_count(supervisor: User, session: CashSession) -> None:
    inventory = stocked("3.50")
    sale_service.create_sale(
        sale_input([item(inventory, "2")], [cash_usd("4.00"), mobile("450.00")]), supervisor
    )

    summary = cash_count_service.build_summary(session)

    assert summary.cash_sales_usd == Decimal("4.00")
    assert summary.electronic_sales_ves == Decimal("450.00")
    assert summary.expected_cash_usd == Decimal("24.00")  # fondo de 20 + 4


# --- Reglas que impiden la venta --------------------------------------------


def test_sale_requires_an_open_session(supervisor: User) -> None:
    ExchangeRateFactory()
    CashSessionFactory(user=supervisor, closed_at=timezone.now())
    inventory = stocked("1.00")

    with pytest.raises(NoOpenSessionError) as exc_info:
        sale_service.create_sale(sale_input([item(inventory, "1")], [cash_usd("1.00")]), supervisor)

    assert exc_info.value.status_code == 409
    assert_nothing_persisted()


def test_sale_in_a_branch_without_open_session(manager: User) -> None:
    ExchangeRateFactory()
    CashSessionFactory(user=manager, branch=VILLA_LIBERTAD)
    inventory = stocked("1.00", branch=LAS_AMERICAS)

    with pytest.raises(NoOpenSessionError):
        sale_service.create_sale(
            sale_input([item(inventory, "1")], [cash_usd("1.00")], branch=LAS_AMERICAS),
            manager,
        )


def test_supervisor_cannot_sell_in_another_branch(supervisor: User, session: CashSession) -> None:
    inventory = stocked("1.00", branch=LAS_AMERICAS)

    with pytest.raises(BranchAccessDeniedError):
        sale_service.create_sale(
            sale_input([item(inventory, "1")], [cash_usd("1.00")], branch=LAS_AMERICAS),
            supervisor,
        )


def test_sale_uses_the_stock_of_the_session_branch(manager: User) -> None:
    ExchangeRateFactory()
    CashSessionFactory(user=manager, branch=LAS_AMERICAS)
    here = stocked("1.00", stock="5.000", branch=LAS_AMERICAS)
    there = BranchInventoryFactory(
        product=here.product, branch=VILLA_LIBERTAD, current_stock=Decimal("5.000")
    )

    sale = sale_service.create_sale(sale_input([item(here, "2")], [cash_usd("2.00")]), manager)

    here.refresh_from_db()
    there.refresh_from_db()
    assert sale.branch_id == LAS_AMERICAS
    assert (here.current_stock, there.current_stock) == (Decimal("3.000"), Decimal("5.000"))


def test_sale_requires_an_exchange_rate(supervisor: User) -> None:
    CashSessionFactory(user=supervisor)
    inventory = stocked("1.00")

    with pytest.raises(DomainError) as exc_info:
        sale_service.create_sale(sale_input([item(inventory, "1")], [cash_usd("1.00")]), supervisor)

    assert exc_info.value.code == "exchange_rate_not_set"


def test_inactive_or_unknown_product(supervisor: User, session: CashSession) -> None:
    inactive = BranchInventoryFactory(product=ProductFactory(active=False))

    with pytest.raises(InactiveProductError) as exc_info:
        sale_service.create_sale(
            sale_input(
                [item(inactive, "1"), SaleItemInput(999_999, Decimal("1"))], [cash_usd("1.50")]
            ),
            supervisor,
        )

    assert exc_info.value.meta == {"product_ids": [inactive.product_id, 999_999]}
    assert_nothing_persisted()


def test_payments_must_match_the_total(supervisor: User, session: CashSession) -> None:
    inventory = stocked("3.50")

    with pytest.raises(PaymentMismatchError) as exc_info:
        sale_service.create_sale(
            sale_input([item(inventory, "2")], [cash_usd("5.00"), mobile("150.00")]), supervisor
        )

    assert exc_info.value.meta["expected_usd"] == "7.00"
    assert exc_info.value.meta["paid_usd"] == "6.00"
    assert_nothing_persisted()
    inventory.refresh_from_db()
    assert inventory.current_stock == Decimal("10.000")


def test_payment_within_tolerance_is_accepted(supervisor: User, session: CashSession) -> None:
    inventory = stocked("3.50")

    sale = sale_service.create_sale(
        sale_input([item(inventory, "2")], [cash_usd("6.99")]), supervisor
    )

    assert sale.total_usd == Decimal("7.00")
    assert sale.payments.get().amount == Decimal("6.99")


def test_insufficient_stock_rolls_everything_back(supervisor: User, session: CashSession) -> None:
    enough = stocked("1.00", stock="10.000")
    short = stocked("1.00", stock="1.000")

    with pytest.raises(InsufficientStockError) as exc_info:
        sale_service.create_sale(
            sale_input([item(enough, "2"), item(short, "1.5")], [cash_usd("3.50")]), supervisor
        )

    assert exc_info.value.meta == {
        "items": [{"product_id": short.product_id, "requested": "1.500", "available": "1.000"}]
    }
    assert_nothing_persisted()
    enough.refresh_from_db()
    assert enough.current_stock == Decimal("10.000")


def test_failure_after_inserting_the_sale_rolls_back(
    supervisor: User, session: CashSession, monkeypatch: pytest.MonkeyPatch
) -> None:
    inventory = stocked("1.00")

    def explode(**kwargs: object) -> None:
        raise RuntimeError("fallo al descontar stock")

    monkeypatch.setattr("apps.inventory.services.stock_service.discount_for_sale", explode)

    with pytest.raises(RuntimeError):
        sale_service.create_sale(sale_input([item(inventory, "1")], [cash_usd("1.00")]), supervisor)

    assert_nothing_persisted()


@pytest.mark.parametrize(
    "payment",
    [
        PaymentInput(PaymentMethod.CASH_USD, Currency.VES, Decimal("150.00")),
        PaymentInput(PaymentMethod.CASH_VES, Currency.USD, Decimal("1.00")),
        PaymentInput(PaymentMethod.POS_CARD, Currency.VES, Decimal("150.00")),  # sin referencia
        PaymentInput(PaymentMethod.MOBILE_PAYMENT, Currency.VES, Decimal("150.00"), "   "),
        PaymentInput(PaymentMethod.CASH_USD, Currency.USD, Decimal("0")),
    ],
)
def test_invalid_payment(supervisor: User, session: CashSession, payment: PaymentInput) -> None:
    inventory = stocked("1.00")

    with pytest.raises(DomainError) as exc_info:
        sale_service.create_sale(sale_input([item(inventory, "1")], [payment]), supervisor)

    assert exc_info.value.code == "invalid_payment"
    assert exc_info.value.status_code == 422
    assert_nothing_persisted()


def test_invalid_items(supervisor: User, session: CashSession) -> None:
    inventory = stocked("1.00")

    with pytest.raises(DomainError) as exc_info:
        sale_service.create_sale(sale_input([], [cash_usd("1.00")]), supervisor)
    assert exc_info.value.code == "empty_sale"
    with pytest.raises(DomainError) as exc_info:
        sale_service.create_sale(sale_input([item(inventory, "0")], [cash_usd("1.00")]), supervisor)
    assert exc_info.value.code == "invalid_quantity"
    with pytest.raises(DomainError) as exc_info:
        sale_service.create_sale(sale_input([item(inventory, "1")], []), supervisor)
    assert exc_info.value.code == "invalid_payment"


# --- Concurrencia -----------------------------------------------------------


@pytest.mark.django_db(transaction=True)
def test_concurrent_sales_cannot_oversell() -> None:
    ExchangeRateFactory()
    inventory = stocked("1.00", stock="10.000")
    sellers = [UserFactory(), UserFactory()]
    for seller in sellers:
        CashSessionFactory(user=seller)
    barrier = threading.Barrier(2)
    outcomes: list[str] = []

    def worker(seller: User) -> None:
        try:
            barrier.wait(timeout=10)
            sale_service.create_sale(sale_input([item(inventory, "6")], [cash_usd("6.00")]), seller)
            outcomes.append("ok")
        except InsufficientStockError:
            outcomes.append("insufficient")
        finally:
            connection.close()

    threads = [threading.Thread(target=worker, args=(seller,)) for seller in sellers]
    for thread in threads:
        thread.start()
    for thread in threads:
        thread.join(timeout=30)

    inventory.refresh_from_db()
    assert sorted(outcomes) == ["insufficient", "ok"]
    assert inventory.current_stock == Decimal("4.000")
    assert Sale.objects.count() == 1
    assert InventoryMovement.objects.count() == 1


@pytest.mark.django_db(transaction=True)
def test_session_closed_before_the_transaction_blocks_the_sale(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    # La caja se cierra justo después de la comprobación inicial: la segunda
    # comprobación, ya con la fila bloqueada, debe detener la venta.
    ExchangeRateFactory()
    seller = UserFactory()
    session = CashSessionFactory(user=seller)
    inventory = stocked("1.00")
    original = sale_service.sale_calculator.validate_payments

    def close_then_validate(*args: object, **kwargs: object) -> Decimal:
        cash_session_service.close_session(
            session_id=session.pk,
            user=seller,
            counted_amount_usd=Decimal("20.00"),
            counted_amount_ves=Decimal("0"),
        )
        return original(*args, **kwargs)

    monkeypatch.setattr(sale_service.sale_calculator, "validate_payments", close_then_validate)

    with pytest.raises(NoOpenSessionError):
        sale_service.create_sale(sale_input([item(inventory, "1")], [cash_usd("1.00")]), seller)

    assert_nothing_persisted()


# --- Consultas --------------------------------------------------------------


def test_list_and_summary_are_scoped(supervisor: User, manager: User) -> None:
    own = SaleFactory(
        cash_session__user=supervisor, total_usd=Decimal("10.00"), total_ves=Decimal("1500.00")
    )
    other = SaleFactory(
        cash_session__branch=LAS_AMERICAS,
        total_usd=Decimal("4.00"),
        total_ves=Decimal("600.00"),
    )
    tomorrow = timezone.now() + timedelta(days=1)

    assert list(sale_service.list_sales(supervisor)) == [own]
    assert set(sale_service.list_sales(manager)) == {own, other}
    assert list(sale_service.list_sales(manager, cash_session_id=other.cash_session_id)) == [other]
    assert list(sale_service.list_sales(manager, date_from=tomorrow)) == []
    with pytest.raises(BranchAccessDeniedError):
        sale_service.list_sales(supervisor, branch=LAS_AMERICAS)
    with pytest.raises(BranchAccessDeniedError):
        sale_service.get_sale(other.pk, supervisor)
    with pytest.raises(DomainError) as exc_info:
        sale_service.get_sale(999_999, manager)
    assert exc_info.value.code == "sale_not_found"

    assert sale_service.get_sales_summary(supervisor) == {
        "sales_count": 1,
        "total_usd": Decimal("10.00"),
        "total_ves": Decimal("1500.00"),
    }
    assert sale_service.get_sales_summary(manager)["total_usd"] == Decimal("14.00")
    assert sale_service.get_sales_summary(manager, date_from=tomorrow) == {
        "sales_count": 0,
        "total_usd": Decimal("0.00"),
        "total_ves": Decimal("0.00"),
    }


# --- API --------------------------------------------------------------------


def test_sale_through_api(api_client: APIClient, supervisor: User, session: CashSession) -> None:
    inventory = stocked("3.50")
    api_client.force_authenticate(supervisor)
    payload = {
        "customer_name": "Ana",
        # El precio enviado por el cliente se ignora: siempre sale de la BD.
        "items": [{"product_id": inventory.product_id, "quantity": "2", "unit_price_usd": "0.01"}],
        "payments": [
            {"method": "CASH_USD", "currency": "USD", "amount": "4.00"},
            {
                "method": "POS_CARD",
                "currency": "VES",
                "amount": "450.00",
                "approval_reference": "A1",
            },
        ],
    }

    created = api_client.post(SALES_URL, payload, format="json")

    assert created.status_code == 201
    assert created.data["total_usd"] == "7.00"
    assert created.data["total_ves"] == "1050.00"
    assert created.data["exchange_rate_at_invoice"] == "150.0000"
    assert created.data["details"][0]["unit_price_usd"] == "3.50"
    assert len(created.data["payments"]) == 2

    detail = api_client.get(f"{SALES_URL}{created.data['id']}/")
    assert detail.status_code == 200
    assert detail.data["id"] == created.data["id"]
    assert api_client.get(SALES_URL).data["count"] == 1
    summary = api_client.get(f"{SALES_URL}reports/summary/")
    assert summary.data == {"sales_count": 1, "total_usd": "7.00", "total_ves": "1050.00"}
    kardex = api_client.get("/api/v1/inventory/movements/", {"movement_type": "SALE"})
    assert kardex.data["results"][0]["sale"] == created.data["id"]


def test_api_error_responses(api_client: APIClient, supervisor: User, session: CashSession) -> None:
    inventory = stocked("3.50", stock="1.000")
    api_client.force_authenticate(supervisor)
    line = {"product_id": inventory.product_id, "quantity": "2"}
    cash = {"method": "CASH_USD", "currency": "USD", "amount": "7.00"}

    no_stock = api_client.post(SALES_URL, {"items": [line], "payments": [cash]}, format="json")
    assert no_stock.status_code == 422
    assert no_stock.data["code"] == "insufficient_stock"

    mismatch = api_client.post(
        SALES_URL, {"items": [line], "payments": [{**cash, "amount": "1.00"}]}, format="json"
    )
    assert mismatch.status_code == 422
    assert mismatch.data["code"] == "payment_mismatch"

    assert (
        api_client.post(SALES_URL, {"items": [], "payments": [cash]}, format="json").status_code
        == 400
    )
    assert api_client.get(SALES_URL, {"date_from": "ayer"}).status_code == 400
    assert api_client.get(SALES_URL, {"branch": "LAS_AMERICAS"}).status_code == 403
    assert api_client.get(f"{SALES_URL}999999/").status_code == 404

    cash_session_service.close_session(
        session_id=session.pk,
        user=supervisor,
        counted_amount_usd=Decimal("20"),
        counted_amount_ves=Decimal("0"),
    )
    closed = api_client.post(SALES_URL, {"items": [line], "payments": [cash]}, format="json")
    assert closed.status_code == 409
    assert closed.data["code"] == "no_open_session"
