from datetime import date
from decimal import Decimal

import pytest

from apps.statistics.domain.dtos import Period
from apps.statistics.domain.enums import Quadrant
from apps.statistics.services import metrics


@pytest.mark.parametrize(
    ("profit", "revenue", "expected"),
    [
        ("14", "52", "26.92"),
        ("-1", "5", "-20.00"),  # una ganancia negativa da un margen negativo
        ("0", "0", "0.00"),  # sin ingresos no se divide
        ("1", "3", "33.33"),
    ],
)
def test_margin_percent(profit: str, revenue: str, expected: str) -> None:
    assert metrics.margin_percent(Decimal(profit), Decimal(revenue)) == Decimal(expected)


def test_average_ticket() -> None:
    assert metrics.average_ticket(Decimal("52.00"), 2) == Decimal("26.00")
    assert metrics.average_ticket(Decimal("10.00"), 3) == Decimal("3.33")
    assert metrics.average_ticket(Decimal("0.00"), 0) == Decimal("0.00")


@pytest.mark.parametrize(
    ("current", "previous", "expected"),
    [
        (Decimal("52"), Decimal("10"), Decimal("420.00")),
        (Decimal("5"), Decimal("10"), Decimal("-50.00")),
        (Decimal("10"), Decimal("0"), None),  # sin período anterior no hay variación
        (2, 1, Decimal("100.00")),
        # Pasar de perder 10 a ganar 5 es mejorar: la variación es positiva.
        (Decimal("5"), Decimal("-10"), Decimal("150.00")),
    ],
)
def test_change_percent(
    current: Decimal | int, previous: Decimal | int, expected: Decimal | None
) -> None:
    assert metrics.change_percent(current, previous) == expected


def test_resolve_period_defaults_to_the_last_30_days() -> None:
    today = date(2026, 3, 31)

    assert metrics.resolve_period(None, None, today=today) == Period(date(2026, 3, 2), today)
    assert metrics.resolve_period(date(2026, 1, 1), None, today=today) == Period(
        date(2026, 1, 1), today
    )
    # Solo con la fecha final, los 30 días se cuentan hacia atrás desde ella.
    assert metrics.resolve_period(None, date(2026, 1, 30), today=today) == Period(
        date(2026, 1, 1), date(2026, 1, 30)
    )


def test_previous_period_has_the_same_length_and_ends_the_day_before() -> None:
    assert metrics.previous_period(Period(date(2026, 3, 2), date(2026, 3, 31))) == Period(
        date(2026, 1, 31), date(2026, 3, 1)
    )
    # Un período de un solo día se compara con el día anterior.
    assert metrics.previous_period(Period(date(2026, 3, 1), date(2026, 3, 1))) == Period(
        date(2026, 2, 28), date(2026, 2, 28)
    )


@pytest.mark.parametrize(
    ("values", "expected"),
    [
        ([], "0.00"),
        (["7"], "7"),
        (["1", "20"], "10.5"),
        (["20", "1", "10"], "10"),
        (["-20", "50", "16.67", "33.33"], "25.00"),
    ],
)
def test_median(values: list[str], expected: str) -> None:
    assert metrics.median([Decimal(value) for value in values]) == Decimal(expected)


@pytest.mark.parametrize(
    ("units", "margin", "expected"),
    [
        ("10", "50", Quadrant.STAR),
        ("6", "25", Quadrant.STAR),  # igualar las dos medianas cuenta como estrella
        ("20", "16.67", Quadrant.VOLUME_DRIVER),
        ("1", "33.33", Quadrant.PROFITABLE_NICHE),
        ("2", "-20", Quadrant.REVIEW),
    ],
)
def test_quadrant(units: str, margin: str, expected: Quadrant) -> None:
    result = metrics.quadrant(
        Decimal(units), Decimal(margin), median_units=Decimal("6"), median_margin=Decimal("25")
    )

    assert result == expected


def test_days_left() -> None:
    assert metrics.days_left(Decimal("3.000"), Decimal(10) / 30) == Decimal("9.0")
    assert metrics.days_left(Decimal("0.000"), Decimal(1) / 30) == Decimal("0.0")
