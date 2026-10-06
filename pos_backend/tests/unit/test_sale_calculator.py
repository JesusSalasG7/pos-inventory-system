from decimal import Decimal

import pytest

from apps.sales.domain.dtos import PaymentInput, PricedLine
from apps.sales.services import sale_calculator
from core.enums import Currency, PaymentMethod
from core.exceptions import PaymentMismatchError

RATE = Decimal("150.0000")


def usd(amount: str) -> PaymentInput:
    return PaymentInput(PaymentMethod.CASH_USD, Currency.USD, Decimal(amount))


def ves(amount: str, method: PaymentMethod = PaymentMethod.CASH_VES) -> PaymentInput:
    return PaymentInput(method, Currency.VES, Decimal(amount))


def test_line_subtotal_rounds_half_up() -> None:
    # 2.5 × 3.33 = 8.325 → 8.33
    assert sale_calculator.calculate_line_subtotal(Decimal("2.500"), Decimal("3.33")) == Decimal(
        "8.33"
    )


def test_calculate_totals() -> None:
    lines = [
        PricedLine(product_id=1, quantity=Decimal("2.500"), unit_price_usd=Decimal("3.50")),
        PricedLine(product_id=2, quantity=Decimal("1"), unit_price_usd=Decimal("5.00")),
    ]

    totals = sale_calculator.calculate_totals(lines, RATE)

    assert [line.subtotal_usd for line in totals.lines] == [Decimal("8.75"), Decimal("5.00")]
    assert totals.total_usd == Decimal("13.75")
    assert totals.total_ves == Decimal("2062.50")


def test_total_usd_is_the_sum_of_rounded_subtotals() -> None:
    # Cada línea vale 0.335 → 0.34; el total es 0.68 y no round(0.67) = 0.67.
    lines = [PricedLine(i, Decimal("0.500"), Decimal("0.67")) for i in (1, 2)]

    assert sale_calculator.calculate_totals(lines, RATE).total_usd == Decimal("0.68")


def test_empty_sale_totals_zero() -> None:
    totals = sale_calculator.calculate_totals([], RATE)

    assert totals.total_usd == Decimal("0.00")
    assert totals.total_ves == Decimal("0.00")


def test_mixed_usd_and_ves_payments_match() -> None:
    payments = [usd("10.00"), ves("562.50", PaymentMethod.MOBILE_PAYMENT)]

    assert sale_calculator.validate_payments(Decimal("13.75"), payments, RATE) == Decimal("13.75")


def test_ves_payments_are_summed_before_converting() -> None:
    # 3 pagos de 0.50 VES: convertidos uno a uno darían 0.00 USD cada uno.
    payments = [ves("0.50"), ves("0.50"), ves("0.50")]

    assert sale_calculator.payments_total_usd(payments, RATE) == Decimal("0.01")


@pytest.mark.parametrize("ves_amount", ["561.00", "564.00"])  # 3.74 y 3.76 USD
def test_difference_within_tolerance_is_accepted(ves_amount: str) -> None:
    payments = [usd("10.00"), ves(ves_amount)]

    sale_calculator.validate_payments(Decimal("13.75"), payments, RATE)


def test_underpayment_beyond_tolerance_fails() -> None:
    payments = [usd("10.00"), ves("559.50")]  # 3.73 USD: faltan 0.02

    with pytest.raises(PaymentMismatchError) as exc_info:
        sale_calculator.validate_payments(Decimal("13.75"), payments, RATE)

    assert exc_info.value.status_code == 422
    assert exc_info.value.meta == {
        "expected_usd": "13.75",
        "paid_usd": "13.73",
        "difference_usd": "-0.02",
        "tolerance_usd": "0.01",
    }


def test_overpayment_beyond_tolerance_fails() -> None:
    with pytest.raises(PaymentMismatchError):
        sale_calculator.validate_payments(Decimal("13.75"), [usd("20.00")], RATE)


def test_custom_tolerance() -> None:
    payments = [usd("13.70")]

    sale_calculator.validate_payments(
        Decimal("13.75"), payments, RATE, tolerance_usd=Decimal("0.05")
    )
    with pytest.raises(PaymentMismatchError):
        sale_calculator.validate_payments(
            Decimal("13.75"), payments, RATE, tolerance_usd=Decimal("0.04")
        )


def test_no_payments_fails() -> None:
    with pytest.raises(PaymentMismatchError):
        sale_calculator.validate_payments(Decimal("13.75"), [], RATE)
