from decimal import Decimal

import pytest
from django.utils import timezone
from rest_framework.test import APIClient

from apps.auth.models import User
from apps.cash_sessions.models import CashSession
from apps.cash_sessions.services import cash_count_service, cash_session_service
from core.enums import Currency, PaymentMethod, Role
from core.exceptions import BranchAccessDeniedError, DomainError, NoOpenSessionError
from tests.factories import (
    LAS_AMERICAS,
    VILLA_LIBERTAD,
    CashSessionFactory,
    ExchangeRateFactory,
    SaleFactory,
    SalePaymentFactory,
    UserFactory,
)

pytestmark = pytest.mark.django_db

SESSIONS_URL = "/api/v1/cash-sessions/"


def pay(session: CashSession, method: str, currency: str, amount: str) -> None:
    SalePaymentFactory(
        sale=SaleFactory(cash_session=session),
        method=method,
        currency=currency,
        amount=Decimal(amount),
    )


# --- Apertura ---------------------------------------------------------------


def test_supervisor_opens_session_in_own_branch_by_default(supervisor: User) -> None:
    session = cash_session_service.open_session(
        user=supervisor, branch=None, opening_float=Decimal("20.00")
    )

    assert session.branch_id == VILLA_LIBERTAD
    assert session.user == supervisor
    assert session.is_open
    assert session.opening_float == Decimal("20.00")


def test_supervisor_cannot_open_session_in_another_branch(supervisor: User) -> None:
    with pytest.raises(BranchAccessDeniedError):
        cash_session_service.open_session(
            user=supervisor, branch=LAS_AMERICAS, opening_float=Decimal("0")
        )


def test_manager_must_choose_branch(manager: User) -> None:
    with pytest.raises(DomainError) as exc_info:
        cash_session_service.open_session(user=manager, branch=None, opening_float=Decimal("0"))
    assert exc_info.value.code == "branch_required"

    session = cash_session_service.open_session(
        user=manager, branch=LAS_AMERICAS, opening_float=Decimal("0")
    )
    assert session.branch_id == LAS_AMERICAS


def test_cannot_open_second_session(supervisor: User) -> None:
    first = cash_session_service.open_session(
        user=supervisor, branch=None, opening_float=Decimal("0")
    )

    with pytest.raises(DomainError) as exc_info:
        cash_session_service.open_session(user=supervisor, branch=None, opening_float=Decimal("0"))

    assert exc_info.value.code == "session_already_open"
    assert exc_info.value.status_code == 409
    assert exc_info.value.meta["cash_session_id"] == first.pk


def test_integrity_error_from_race_is_translated(
    supervisor: User, monkeypatch: pytest.MonkeyPatch
) -> None:
    # Simula la carrera: la comprobación previa no ve la caja que otra petición
    # acaba de abrir, y es la restricción de la BD la que detiene la segunda.
    existing = CashSessionFactory(user=supervisor)
    lookups = iter([None, existing])
    monkeypatch.setattr(
        "apps.cash_sessions.repositories.cash_session_repository.get_open_by_user",
        lambda user_id: next(lookups),
    )

    with pytest.raises(DomainError) as exc_info:
        cash_session_service.open_session(user=supervisor, branch=None, opening_float=Decimal("0"))

    assert exc_info.value.code == "session_already_open"
    assert CashSession.objects.count() == 1


def test_negative_opening_float_is_rejected(supervisor: User) -> None:
    with pytest.raises(DomainError) as exc_info:
        cash_session_service.open_session(
            user=supervisor, branch=None, opening_float=Decimal("-0.01")
        )
    assert exc_info.value.code == "invalid_amount"


# --- Caja abierta -----------------------------------------------------------


def test_get_open_session(supervisor: User) -> None:
    CashSessionFactory(user=supervisor, closed_at=timezone.now())
    session = CashSessionFactory(user=supervisor)

    assert cash_session_service.get_open_session(supervisor) == session
    assert cash_session_service.get_open_session(supervisor, VILLA_LIBERTAD) == session


def test_get_open_session_without_session(supervisor: User) -> None:
    CashSessionFactory(user=supervisor, closed_at=timezone.now())
    CashSessionFactory()  # caja abierta de otro usuario

    with pytest.raises(NoOpenSessionError) as exc_info:
        cash_session_service.get_open_session(supervisor)
    assert exc_info.value.status_code == 409


def test_get_open_session_in_another_branch(manager: User) -> None:
    CashSessionFactory(user=manager, branch=VILLA_LIBERTAD)

    with pytest.raises(NoOpenSessionError):
        cash_session_service.get_open_session(manager, LAS_AMERICAS)


# --- Egresos ----------------------------------------------------------------


def test_register_expense(supervisor: User) -> None:
    session = CashSessionFactory(user=supervisor)

    expense = cash_session_service.register_expense(
        session_id=session.pk,
        user=supervisor,
        reason="  Bolsas  ",
        amount=Decimal("5.50"),
        currency=Currency.USD,
    )

    assert expense.reason == "Bolsas"
    assert expense.created_by == supervisor
    assert list(cash_session_service.list_expenses(session.pk, supervisor)) == [expense]


@pytest.mark.parametrize(
    ("reason", "amount", "code"),
    [
        ("Bolsas", "0", "invalid_amount"),
        ("Bolsas", "-1", "invalid_amount"),
        ("  ", "1", "invalid_reason"),
    ],
)
def test_register_expense_validates_input(
    supervisor: User, reason: str, amount: str, code: str
) -> None:
    session = CashSessionFactory(user=supervisor)

    with pytest.raises(DomainError) as exc_info:
        cash_session_service.register_expense(
            session_id=session.pk,
            user=supervisor,
            reason=reason,
            amount=Decimal(amount),
            currency=Currency.USD,
        )
    assert exc_info.value.code == code


def test_cannot_register_expense_in_closed_session(supervisor: User) -> None:
    session = CashSessionFactory(user=supervisor, closed_at=timezone.now())

    with pytest.raises(DomainError) as exc_info:
        cash_session_service.register_expense(
            session_id=session.pk,
            user=supervisor,
            reason="Bolsas",
            amount=Decimal("1"),
            currency=Currency.USD,
        )
    assert exc_info.value.code == "session_already_closed"


def test_other_supervisor_cannot_operate_on_session(supervisor: User) -> None:
    session = CashSessionFactory(user=supervisor)
    colleague = UserFactory()  # misma sucursal, pero no es el dueño

    with pytest.raises(DomainError) as exc_info:
        cash_session_service.register_expense(
            session_id=session.pk,
            user=colleague,
            reason="Bolsas",
            amount=Decimal("1"),
            currency=Currency.USD,
        )
    assert exc_info.value.code == "not_session_owner"

    with pytest.raises(DomainError) as exc_info:
        cash_session_service.close_session(
            session_id=session.pk,
            user=colleague,
            counted_amount_usd=Decimal("0"),
            counted_amount_ves=Decimal("0"),
        )
    assert exc_info.value.code == "not_session_owner"


def test_supervisor_cannot_see_session_of_another_branch(supervisor: User) -> None:
    session = CashSessionFactory(branch=LAS_AMERICAS)

    with pytest.raises(BranchAccessDeniedError):
        cash_session_service.get_session(session.pk, supervisor)
    with pytest.raises(BranchAccessDeniedError):
        cash_session_service.list_expenses(session.pk, supervisor)


def test_unknown_session(supervisor: User) -> None:
    with pytest.raises(DomainError) as exc_info:
        cash_session_service.get_session(999_999, supervisor)

    assert exc_info.value.code == "cash_session_not_found"
    assert exc_info.value.status_code == 404


# --- Arqueo y cierre --------------------------------------------------------


def make_busy_session(user: User) -> CashSession:
    """Caja con fondo de 20 USD, ventas mixtas y egresos en ambas monedas."""
    session = CashSessionFactory(user=user, opening_float=Decimal("20.00"))
    pay(session, PaymentMethod.CASH_USD, Currency.USD, "30.00")
    pay(session, PaymentMethod.CASH_USD, Currency.USD, "12.50")
    pay(session, PaymentMethod.CASH_VES, Currency.VES, "3000.00")
    pay(session, PaymentMethod.POS_CARD, Currency.VES, "4500.00")
    pay(session, PaymentMethod.MOBILE_PAYMENT, Currency.VES, "1500.00")
    for reason, amount, currency in [
        ("Agua", "2.50", Currency.USD),
        ("Taxi", "600.00", Currency.VES),
    ]:
        cash_session_service.register_expense(
            session_id=session.pk,
            user=user,
            reason=reason,
            amount=Decimal(amount),
            currency=currency,
        )
    pay(CashSessionFactory(), PaymentMethod.CASH_USD, Currency.USD, "999.00")  # otra caja
    return session


def test_summary(supervisor: User) -> None:
    summary = cash_count_service.build_summary(make_busy_session(supervisor))

    assert summary.opening_float == Decimal("20.00")
    assert summary.cash_sales_usd == Decimal("42.50")
    assert summary.cash_sales_ves == Decimal("3000.00")
    assert summary.electronic_sales_usd == Decimal("0.00")
    assert summary.electronic_sales_ves == Decimal("6000.00")
    assert summary.expenses_usd == Decimal("2.50")
    assert summary.expenses_ves == Decimal("600.00")
    assert summary.expected_cash_usd == Decimal("60.00")  # 20 + 42.50 − 2.50
    assert summary.expected_cash_ves == Decimal("2400.00")  # 3000 − 600


def test_summary_of_empty_session(supervisor: User) -> None:
    summary = cash_count_service.build_summary(CashSessionFactory(user=supervisor))

    assert summary.expected_cash_usd == Decimal("20.00")
    assert summary.expected_cash_ves == Decimal("0.00")


@pytest.mark.parametrize(
    ("counted_usd", "counted_ves", "difference"),
    [
        ("60.00", "2400.00", "0.00"),  # cuadra
        ("58.00", "2400.00", "-2.00"),  # faltan 2 USD
        ("60.00", "2550.00", "1.00"),  # sobran 150 VES = 1 USD a tasa 150
        ("61.00", "2100.00", "-1.00"),  # +1 USD y −300 VES (−2 USD)
    ],
)
def test_close_session_stores_count_and_difference(
    supervisor: User, counted_usd: str, counted_ves: str, difference: str
) -> None:
    ExchangeRateFactory(usd_to_ves_rate=Decimal("150.0000"))
    session = make_busy_session(supervisor)

    closed = cash_session_service.close_session(
        session_id=session.pk,
        user=supervisor,
        counted_amount_usd=Decimal(counted_usd),
        counted_amount_ves=Decimal(counted_ves),
    )

    closed.refresh_from_db()
    assert not closed.is_open
    assert closed.counted_amount_usd == Decimal(counted_usd)
    assert closed.counted_amount_ves == Decimal(counted_ves)
    assert closed.difference_usd == Decimal(difference)


def test_cannot_close_twice(supervisor: User) -> None:
    ExchangeRateFactory()
    session = CashSessionFactory(user=supervisor)
    amounts = {"counted_amount_usd": Decimal("20"), "counted_amount_ves": Decimal("0")}
    cash_session_service.close_session(session_id=session.pk, user=supervisor, **amounts)

    with pytest.raises(DomainError) as exc_info:
        cash_session_service.close_session(session_id=session.pk, user=supervisor, **amounts)
    assert exc_info.value.code == "session_already_closed"


def test_manager_can_close_session_of_a_supervisor(supervisor: User, manager: User) -> None:
    ExchangeRateFactory()
    session = CashSessionFactory(user=supervisor)

    closed = cash_session_service.close_session(
        session_id=session.pk,
        user=manager,
        counted_amount_usd=Decimal("20.00"),
        counted_amount_ves=Decimal("0"),
    )

    assert not closed.is_open
    # Al cerrar, el supervisor puede volver a abrir caja.
    cash_session_service.open_session(user=supervisor, branch=None, opening_float=Decimal("0"))


def test_close_requires_an_exchange_rate(supervisor: User) -> None:
    session = CashSessionFactory(user=supervisor)

    with pytest.raises(DomainError) as exc_info:
        cash_session_service.close_session(
            session_id=session.pk,
            user=supervisor,
            counted_amount_usd=Decimal("20"),
            counted_amount_ves=Decimal("0"),
        )

    assert exc_info.value.code == "exchange_rate_not_set"
    session.refresh_from_db()
    assert session.is_open


def test_close_rejects_negative_counts(supervisor: User) -> None:
    session = CashSessionFactory(user=supervisor)

    with pytest.raises(DomainError) as exc_info:
        cash_session_service.close_session(
            session_id=session.pk,
            user=supervisor,
            counted_amount_usd=Decimal("-1"),
            counted_amount_ves=Decimal("0"),
        )
    assert exc_info.value.code == "invalid_amount"


# --- Listado ----------------------------------------------------------------


def test_list_sessions_is_scoped_by_branch(supervisor: User, manager: User) -> None:
    own = CashSessionFactory(user=supervisor)
    closed = CashSessionFactory(branch=VILLA_LIBERTAD, closed_at=timezone.now())
    other = CashSessionFactory(branch=LAS_AMERICAS)

    assert set(cash_session_service.list_sessions(supervisor)) == {own, closed}
    assert set(cash_session_service.list_sessions(supervisor, only_open=True)) == {own}
    assert set(cash_session_service.list_sessions(manager)) == {own, closed, other}
    assert set(cash_session_service.list_sessions(manager, branch=LAS_AMERICAS)) == {other}
    with pytest.raises(BranchAccessDeniedError):
        cash_session_service.list_sessions(supervisor, branch=LAS_AMERICAS)


# --- API --------------------------------------------------------------------


def test_full_session_lifecycle_through_api(api_client: APIClient, supervisor: User) -> None:
    ExchangeRateFactory(usd_to_ves_rate=Decimal("150.0000"))
    api_client.force_authenticate(supervisor)

    assert api_client.get(f"{SESSIONS_URL}current/").data["code"] == "no_open_session"

    opened = api_client.post(SESSIONS_URL, {"opening_float": "20.00"}, format="json")
    assert opened.status_code == 201
    session_url = f"{SESSIONS_URL}{opened.data['id']}/"
    assert opened.data["branch"] == VILLA_LIBERTAD
    assert api_client.get(f"{SESSIONS_URL}current/").data["id"] == opened.data["id"]

    again = api_client.post(SESSIONS_URL, {"opening_float": "0"}, format="json")
    assert again.status_code == 409
    assert again.data["code"] == "session_already_open"

    expense = api_client.post(
        f"{session_url}expenses/",
        {"reason": "Agua", "amount": "2.50", "currency": "USD"},
        format="json",
    )
    assert expense.status_code == 201
    assert api_client.get(f"{session_url}expenses/").data["count"] == 1

    summary = api_client.get(f"{session_url}summary/")
    assert summary.status_code == 200
    assert summary.data["expected_cash_usd"] == "17.50"

    closed = api_client.post(
        f"{session_url}close/",
        {"counted_amount_usd": "17.00", "counted_amount_ves": "0.00"},
        format="json",
    )
    assert closed.status_code == 200
    assert closed.data["difference_usd"] == "-0.50"
    assert closed.data["closed_at"] is not None

    listing = api_client.get(SESSIONS_URL, {"only_open": "true"})
    assert listing.status_code == 200
    assert listing.data["count"] == 0


def test_api_blocks_other_branch_and_unknown_session(
    api_client: APIClient, supervisor: User
) -> None:
    foreign = CashSessionFactory(branch=LAS_AMERICAS)
    api_client.force_authenticate(supervisor)

    assert api_client.get(f"{SESSIONS_URL}{foreign.pk}/summary/").status_code == 403
    assert api_client.get(SESSIONS_URL, {"branch": "LAS_AMERICAS"}).status_code == 403
    missing = api_client.get(f"{SESSIONS_URL}999999/summary/")
    assert missing.status_code == 404
    assert missing.data["code"] == "cash_session_not_found"


def test_api_requires_operator_role(api_client: APIClient) -> None:
    api_client.force_authenticate(UserFactory(role=Role.SUPERVISOR, is_active=True))
    assert api_client.get(SESSIONS_URL).status_code == 200

    api_client.force_authenticate(None)
    assert api_client.get(SESSIONS_URL).status_code == 401
