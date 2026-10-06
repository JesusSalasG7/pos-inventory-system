from decimal import Decimal

import pytest

from core.money import (
    quantize_money,
    quantize_quantity,
    quantize_rate,
    to_decimal,
    usd_to_ves,
    ves_to_usd,
)


@pytest.mark.parametrize(
    ("raw", "expected"),
    [
        ("1.005", "1.01"),  # la mitad redondea hacia arriba, no al par
        ("1.004", "1.00"),
        ("2.675", "2.68"),
        ("-1.005", "-1.01"),
        (3, "3.00"),
    ],
)
def test_quantize_money_rounds_half_up(raw: str | int, expected: str) -> None:
    assert quantize_money(raw) == Decimal(expected)


def test_quantize_rate_and_quantity_precision() -> None:
    assert quantize_rate("150.25005") == Decimal("150.2501")
    assert quantize_quantity("2.4995") == Decimal("2.500")


def test_float_is_rejected() -> None:
    with pytest.raises(TypeError):
        to_decimal(0.1)  # type: ignore[arg-type]
    with pytest.raises(TypeError):
        quantize_money(1.5)  # type: ignore[arg-type]


def test_bool_is_rejected() -> None:
    with pytest.raises(TypeError):
        to_decimal(True)


def test_usd_to_ves() -> None:
    assert usd_to_ves(Decimal("13.75"), Decimal("150.2500")) == Decimal("2065.94")


def test_ves_to_usd() -> None:
    assert ves_to_usd(Decimal("563.44"), Decimal("150.2500")) == Decimal("3.75")


@pytest.mark.parametrize("rate", ["0", "-1"])
def test_conversion_requires_positive_rate(rate: str) -> None:
    with pytest.raises(ValueError):
        usd_to_ves(Decimal("1"), Decimal(rate))
    with pytest.raises(ValueError):
        ves_to_usd(Decimal("1"), Decimal(rate))
