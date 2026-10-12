from datetime import UTC, datetime, timedelta
from decimal import Decimal
from typing import Any

import pytest
from django.utils import timezone
from rest_framework.test import APIClient

from apps.auth.models import User
from apps.cash_sessions.models import CashSession
from apps.credits.models import Credit
from apps.inventory.models import Product
from apps.sales.models import Sale, SaleDetail
from apps.statistics.domain.dtos import StatisticsFilters
from apps.statistics.services import statistics_service
from core.exceptions import DomainError
from core.money import quantize_money
from tests.factories import (
    LAS_AMERICAS,
    VILLA_LIBERTAD,
    BranchInventoryFactory,
    CashSessionFactory,
    CategoryFactory,
    CustomerFactory,
    ProductFactory,
    SaleFactory,
    SubcategoryFactory,
)

pytestmark = pytest.mark.django_db

STATISTICS_URL = "/api/v1/statistics/"
HERE = {"branch": VILLA_LIBERTAD}
FILTERS = StatisticsFilters(branch=VILLA_LIBERTAD)


def sell(
    session: CashSession,
    lines: list[tuple[Product, str, str, str]],
    *,
    days_ago: int = 0,
    at: datetime | None = None,
) -> Sale:
    """Venta con líneas (producto, cantidad, precio, costo) fechada en el pasado."""
    sale = SaleFactory(cash_session=session)
    for product, quantity, price, cost in lines:
        SaleDetail.objects.create(
            sale=sale,
            product=product,
            quantity=Decimal(quantity),
            unit_price_usd=Decimal(price),
            unit_cost_usd=Decimal(cost),
            subtotal_usd=quantize_money(Decimal(quantity) * Decimal(price)),
            subtotal_ves=Decimal("0.00"),
        )
    # `created_at` es auto_now_add: solo se puede fijar con un update.
    created_at = at or timezone.now() - timedelta(days=days_ago)
    total = sum(
        (quantize_money(Decimal(quantity) * Decimal(price)) for _, quantity, price, _ in lines),
        Decimal("0.00"),
    )
    Sale.objects.filter(pk=sale.pk).update(created_at=created_at, total_usd=total)
    sale.refresh_from_db()
    return sale


def on_credit(sale: Sale, amount: str, balance: str) -> Credit:
    """Deja parte de la venta como deuda, con lo que hoy falta por cobrar."""
    return Credit.objects.create(
        sale=sale,
        customer=CustomerFactory(),
        branch_id=sale.branch_id,
        amount_usd=Decimal(amount),
        balance_usd=Decimal(balance),
        due_date=timezone.localdate() + timedelta(days=7),
    )


@pytest.fixture
def store() -> dict[str, Any]:
    """Un mes de ventas en VILLA_LIBERTAD.

    Período actual (últimos 30 días), dos ventas:
      Detergente 10 × 2,00 (costo 1,00)  → ingresos 20, ganancia 10
      Ambientador 2 × 2,50 (costo 3,00)  → ingresos  5, ganancia −1
      Cloro      20 × 1,20 (costo 1,00)  → ingresos 24, ganancia  4
      Suavizante  1 × 3,00 (costo 2,00)  → ingresos  3, ganancia  1
    Período anterior, una venta: Detergente 5 × 2,00 → ingresos 10, ganancia 5.
    """
    cleaning = CategoryFactory(name="Limpieza")
    aromas = CategoryFactory(name="Aromas")
    products = {
        "detergent": ProductFactory(
            name="Detergente",
            category=cleaning,
            subcategory=SubcategoryFactory(category=cleaning, name="Detergentes"),
        ),
        "bleach": ProductFactory(
            name="Cloro",
            category=cleaning,
            subcategory=SubcategoryFactory(category=cleaning, name="Cloros"),
        ),
        "softener": ProductFactory(name="Suavizante", category=cleaning),
        "freshener": ProductFactory(name="Ambientador", category=aromas),
        "old": ProductFactory(name="Viejo", category=aromas, cost_price_usd=Decimal("2.50")),
        "new": ProductFactory(name="Nuevo", category=aromas, cost_price_usd=Decimal("1.00")),
    }
    stock = {
        "detergent": "3",
        "bleach": "100",
        "softener": "0",
        "freshener": "50",
        "old": "4",
        "new": "2",
    }
    for key, quantity in stock.items():
        BranchInventoryFactory(product=products[key], current_stock=Decimal(quantity))

    session = CashSessionFactory()
    products["recent_sale"] = sell(
        session,
        [
            (products["detergent"], "10", "2.00", "1.00"),
            (products["freshener"], "2", "2.50", "3.00"),
        ],
        days_ago=2,
    )
    sell(
        session,
        [(products["bleach"], "20", "1.20", "1.00"), (products["softener"], "1", "3.00", "2.00")],
        days_ago=5,
    )
    sell(session, [(products["detergent"], "5", "2.00", "1.00")], days_ago=40)
    sell(session, [(products["old"], "1", "4.00", "2.50")], days_ago=70)
    # Lo vendido en otra sucursal no cuenta.
    other_branch = CashSessionFactory(branch=LAS_AMERICAS)
    sell(other_branch, [(products["detergent"], "100", "2.00", "1.00")])
    return products


def test_summary_compares_with_the_previous_period(store: dict[str, Any]) -> None:
    summary = statistics_service.get_summary(FILTERS)

    today = timezone.localdate()
    assert (summary.period.date_from, summary.period.date_to) == (
        today - timedelta(days=29),
        today,
    )
    assert (summary.previous_period.date_from, summary.previous_period.date_to) == (
        today - timedelta(days=59),
        today - timedelta(days=30),
    )
    current, previous, change = summary.current, summary.previous, summary.change
    assert (current.revenue, current.profit, current.margin) == (
        Decimal("52.00"),
        Decimal("14.00"),
        Decimal("26.92"),
    )
    assert (current.units, current.sales_count, current.average_ticket) == (
        Decimal("33.000"),
        2,
        Decimal("26.00"),
    )
    assert (previous.revenue, previous.profit, previous.margin, previous.sales_count) == (
        Decimal("10.00"),
        Decimal("5.00"),
        Decimal("50.00"),
        1,
    )
    assert (change.revenue, change.profit, change.units) == (
        Decimal("420.00"),
        Decimal("180.00"),
        Decimal("560.00"),
    )
    # El margen varía en puntos porcentuales: 26,92 − 50,00.
    assert change.margin == Decimal("-23.08")
    assert (change.sales_count, change.average_ticket) == (Decimal("100.00"), Decimal("160.00"))


def test_summary_respects_category_and_subcategory(store: dict[str, Any]) -> None:
    detergent = store["detergent"]

    by_category = statistics_service.get_summary(
        StatisticsFilters(branch=VILLA_LIBERTAD, category_id=detergent.category_id)
    )
    # La venta mixta cuenta como venta de la categoría, pero solo con sus líneas.
    assert (by_category.current.revenue, by_category.current.sales_count) == (Decimal("47.00"), 2)

    by_subcategory = statistics_service.get_summary(
        StatisticsFilters(branch=VILLA_LIBERTAD, subcategory_id=detergent.subcategory_id)
    )
    assert (by_subcategory.current.revenue, by_subcategory.current.profit) == (
        Decimal("20.00"),
        Decimal("10.00"),
    )


def test_period_without_sales_is_all_zeros(store: dict[str, Any]) -> None:
    empty = StatisticsFilters(
        branch=VILLA_LIBERTAD,
        date_from=timezone.localdate() - timedelta(days=400),
        date_to=timezone.localdate() - timedelta(days=390),
    )

    summary = statistics_service.get_summary(empty)
    assert (summary.current.revenue, summary.current.margin, summary.current.average_ticket) == (
        Decimal("0.00"),
        Decimal("0.00"),
        Decimal("0.00"),
    )
    assert (summary.current.units, summary.current.sales_count) == (Decimal("0.000"), 0)
    assert (summary.change.revenue, summary.change.margin) == (None, None)

    assert statistics_service.get_group_performance(empty).groups == ()
    assert statistics_service.get_product_ranking(empty).results == ()
    matrix = statistics_service.get_matrix(empty)
    assert (matrix.median_units, matrix.median_margin, matrix.products) == (0, 0, ())


def test_credit_breakdown_without_credit_sales_is_all_cash(store: dict[str, Any]) -> None:
    breakdown = statistics_service.get_credit_breakdown(FILTERS)

    assert (breakdown.cash.revenue, breakdown.cash.profit, breakdown.cash.margin) == (
        Decimal("52.00"),
        Decimal("14.00"),
        Decimal("26.92"),
    )
    assert (breakdown.credit.revenue, breakdown.credit.profit, breakdown.credit.margin) == (0, 0, 0)
    assert (breakdown.pending.revenue, breakdown.pending.profit, breakdown.credit_share) == (
        0,
        0,
        0,
    )


def test_credit_breakdown_splits_a_partly_credit_sale(store: dict[str, Any]) -> None:
    # Venta de 25 (ganancia 9): 10 quedaron a crédito y aún se deben 4.
    on_credit(store["recent_sale"], amount="10.00", balance="4.00")

    breakdown = statistics_service.get_credit_breakdown(FILTERS)

    # El 40 % de la venta es crédito: 10 de ingresos y 3,60 de ganancia.
    assert (breakdown.credit.revenue, breakdown.credit.profit, breakdown.credit.margin) == (
        Decimal("10.00"),
        Decimal("3.60"),
        Decimal("36.00"),
    )
    # Contado es el resto: juntos suman los totales del resumen (52 y 14).
    assert (breakdown.cash.revenue, breakdown.cash.profit, breakdown.cash.margin) == (
        Decimal("42.00"),
        Decimal("10.40"),
        Decimal("24.76"),
    )
    # Falta cobrar el 16 % de la venta, con su parte de la ganancia.
    assert (breakdown.pending.revenue, breakdown.pending.profit) == (
        Decimal("4.00"),
        Decimal("1.44"),
    )
    assert breakdown.credit_share == Decimal("19.23")


def test_credit_breakdown_respects_category_and_paid_debts(store: dict[str, Any]) -> None:
    credit = on_credit(store["recent_sale"], amount="10.00", balance="4.00")
    cleaning = StatisticsFilters(branch=VILLA_LIBERTAD, category_id=store["detergent"].category_id)

    # De esa venta solo el detergente (20, ganancia 10) es de la categoría.
    breakdown = statistics_service.get_credit_breakdown(cleaning)
    assert (breakdown.credit.revenue, breakdown.credit.profit) == (
        Decimal("8.00"),
        Decimal("4.00"),
    )
    assert (breakdown.cash.revenue, breakdown.cash.profit) == (Decimal("39.00"), Decimal("11.00"))

    # Al saldar la deuda sigue siendo una venta a crédito, pero ya sin pendiente.
    Credit.objects.filter(pk=credit.pk).update(balance_usd=Decimal("0.00"))
    paid = statistics_service.get_credit_breakdown(FILTERS)
    assert (paid.credit.revenue, paid.pending.revenue, paid.pending.profit) == (
        Decimal("10.00"),
        0,
        0,
    )


def test_groups_drill_down_from_categories_to_subcategories(store: dict[str, Any]) -> None:
    report = statistics_service.get_group_performance(FILTERS)

    assert (report.level, report.category_id) == ("category", None)
    assert [(g.name, g.units, g.revenue, g.profit, g.margin) for g in report.groups] == [
        ("Limpieza", Decimal("31.000"), Decimal("47.00"), Decimal("15.00"), Decimal("31.91")),
        ("Aromas", Decimal("2.000"), Decimal("5.00"), Decimal("-1.00"), Decimal("-20.00")),
    ]

    cleaning = store["detergent"].category
    inside = statistics_service.get_group_performance(
        StatisticsFilters(branch=VILLA_LIBERTAD, category_id=cleaning.pk)
    )
    assert (inside.level, inside.category_id, inside.category_name) == (
        "subcategory",
        cleaning.pk,
        "Limpieza",
    )
    assert [(g.id, g.name, g.profit, g.margin) for g in inside.groups] == [
        (store["detergent"].subcategory_id, "Detergentes", Decimal("10.00"), Decimal("50.00")),
        (store["bleach"].subcategory_id, "Cloros", Decimal("4.00"), Decimal("16.67")),
        (None, "Sin subcategoría", Decimal("1.00"), Decimal("33.33")),
    ]


def test_product_ranking_orders(store: dict[str, Any]) -> None:
    def names(**kwargs: object) -> list[str]:
        ranking = statistics_service.get_product_ranking(FILTERS, **kwargs)
        return [product.name for product in ranking.results]

    assert names() == ["Detergente", "Cloro", "Suavizante", "Ambientador"]
    assert names(order_by="units") == ["Cloro", "Detergente", "Ambientador", "Suavizante"]
    assert names(order_by="revenue") == ["Cloro", "Detergente", "Ambientador", "Suavizante"]
    # Por margen quedan fuera los que vendieron menos de 5 unidades.
    assert names(order_by="margin") == ["Detergente", "Cloro"]
    assert names(order_by="margin", min_units=Decimal(0)) == [
        "Detergente",
        "Suavizante",
        "Cloro",
        "Ambientador",
    ]
    assert names(order_by="units", limit=1) == ["Cloro"]

    top = statistics_service.get_product_ranking(FILTERS).results[0]
    assert (top.category_name, top.subcategory_name, top.unit_of_measure) == (
        "Limpieza",
        "Detergentes",
        "LITER",
    )
    assert (top.units, top.revenue, top.profit, top.margin) == (
        Decimal("10.000"),
        Decimal("20.00"),
        Decimal("10.00"),
        Decimal("50.00"),
    )


def test_matrix_splits_products_by_the_medians(store: dict[str, Any]) -> None:
    matrix = statistics_service.get_matrix(FILTERS)

    # Unidades 1, 2, 10, 20 → mediana 6. Márgenes −20, 16,67, 33,33, 50 → mediana 25.
    assert (matrix.median_units, matrix.median_margin) == (Decimal("6.000"), Decimal("25.00"))
    assert {point.name: point.quadrant for point in matrix.products} == {
        "Detergente": "STAR",
        "Cloro": "VOLUME_DRIVER",
        "Suavizante": "PROFITABLE_NICHE",
        "Ambientador": "REVIEW",
    }
    assert {entry.quadrant: entry.count for entry in matrix.counts} == {
        "STAR": 1,
        "VOLUME_DRIVER": 1,
        "PROFITABLE_NICHE": 1,
        "REVIEW": 1,
    }


def test_matrix_works_with_one_or_two_products(store: dict[str, Any]) -> None:
    one = statistics_service.get_matrix(
        StatisticsFilters(branch=VILLA_LIBERTAD, category_id=store["freshener"].category_id)
    )
    # Un solo producto es su propia mediana, aunque pierda dinero.
    assert (one.median_units, one.median_margin) == (Decimal("2.000"), Decimal("-20.00"))
    assert [(point.name, point.quadrant) for point in one.products] == [("Ambientador", "STAR")]

    two = statistics_service.get_matrix(
        StatisticsFilters(
            branch=VILLA_LIBERTAD,
            date_from=timezone.localdate() - timedelta(days=3),
        )
    )
    assert (two.median_units, two.median_margin) == (Decimal("6.000"), Decimal("15.00"))
    assert {point.name: point.quadrant for point in two.products} == {
        "Detergente": "STAR",
        "Ambientador": "REVIEW",
    }


def test_inventory_health(store: dict[str, Any]) -> None:
    health = statistics_service.get_inventory_health(FILTERS)

    today = timezone.localdate()
    assert health.as_of == today
    # Con stock y sin ventas en 30 días, o nunca vendidos; primero el más caro.
    assert [
        (item.name, item.stock, item.last_sale_date, item.immobilized_capital)
        for item in health.no_movement
    ] == [
        ("Viejo", Decimal("4.000"), today - timedelta(days=70), Decimal("10.00")),
        ("Nuevo", Decimal("2.000"), None, Decimal("2.00")),
    ]
    assert health.immobilized_capital_total == Decimal("12.00")
    # Detergente: 10 vendidos en 30 días → 0,333 al día → 3 en stock duran 9 días.
    assert [
        (item.name, item.stock, item.daily_rate, item.days_left) for item in health.running_out
    ] == [
        ("Suavizante", Decimal("0.000"), Decimal("0.033"), Decimal("0.0")),
        ("Detergente", Decimal("3.000"), Decimal("0.333"), Decimal("9.0")),
    ]


def test_inventory_health_thresholds_and_category(store: dict[str, Any]) -> None:
    strict = statistics_service.get_inventory_health(FILTERS, no_sales_days=100, max_days_left=5)
    assert [item.name for item in strict.no_movement] == ["Nuevo"]
    assert [item.name for item in strict.running_out] == ["Suavizante"]

    cleaning = statistics_service.get_inventory_health(
        StatisticsFilters(branch=VILLA_LIBERTAD, category_id=store["detergent"].category_id)
    )
    assert cleaning.no_movement == ()
    assert cleaning.immobilized_capital_total == Decimal("0.00")
    assert len(cleaning.running_out) == 2


def test_inactive_products_are_not_reported_as_running_out(store: dict[str, Any]) -> None:
    Product.objects.filter(pk=store["detergent"].pk).update(active=False)

    health = statistics_service.get_inventory_health(FILTERS)

    assert [item.name for item in health.running_out] == ["Suavizante"]


def test_dates_are_read_in_the_store_time_zone() -> None:
    product = ProductFactory()
    # 02:00 UTC del día 10 son las 22:00 del día 9 en Caracas.
    sell(
        CashSessionFactory(),
        [(product, "1", "2.00", "1.00")],
        at=datetime(2026, 3, 10, 2, 0, tzinfo=UTC),
    )

    def revenue(day: int) -> Decimal:
        date = datetime(2026, 3, day).date()
        filters = StatisticsFilters(branch=VILLA_LIBERTAD, date_from=date, date_to=date)
        return statistics_service.get_summary(filters).current.revenue

    assert (revenue(9), revenue(10)) == (Decimal("2.00"), Decimal("0.00"))


def test_cost_is_the_one_frozen_in_the_sale(store: dict[str, Any]) -> None:
    Product.objects.filter(pk=store["detergent"].pk).update(cost_price_usd=Decimal("1.90"))

    assert statistics_service.get_summary(FILTERS).current.profit == Decimal("14.00")


def test_filters_are_validated(store: dict[str, Any]) -> None:
    today = timezone.localdate()
    cases = [
        (
            StatisticsFilters(
                branch=VILLA_LIBERTAD, date_from=today, date_to=today - timedelta(days=1)
            ),
            "invalid_period",
            422,
        ),
        (StatisticsFilters(branch=VILLA_LIBERTAD, category_id=999_999), "category_not_found", 404),
        (
            StatisticsFilters(branch=VILLA_LIBERTAD, subcategory_id=999_999),
            "subcategory_not_found",
            404,
        ),
        (
            StatisticsFilters(
                branch=VILLA_LIBERTAD,
                category_id=store["freshener"].category_id,
                subcategory_id=store["detergent"].subcategory_id,
            ),
            "subcategory_category_mismatch",
            422,
        ),
    ]
    for filters, code, status_code in cases:
        with pytest.raises(DomainError) as exc_info:
            statistics_service.get_summary(filters)
        assert (exc_info.value.code, exc_info.value.status_code) == (code, status_code)


def test_endpoints_return_json_numbers(
    api_client: APIClient, manager: User, store: dict[str, Any]
) -> None:
    api_client.force_authenticate(manager)

    summary = api_client.get(f"{STATISTICS_URL}summary/", HERE).json()
    assert summary["current"] == {
        "revenue": 52.0,
        "profit": 14.0,
        "margin": 26.92,
        "units": 33.0,
        "sales_count": 2,
        "average_ticket": 26.0,
    }
    assert summary["change"]["margin"] == -23.08
    assert summary["period"]["date_to"] == str(timezone.localdate())

    on_credit(store["recent_sale"], amount="10.00", balance="4.00")
    breakdown = api_client.get(f"{STATISTICS_URL}credit-breakdown/", HERE).json()
    assert breakdown == {
        "cash": {"revenue": 42.0, "profit": 10.4, "margin": 24.76},
        "credit": {"revenue": 10.0, "profit": 3.6, "margin": 36.0},
        "pending": {"revenue": 4.0, "profit": 1.44},
        "credit_share": 19.23,
    }

    cleaning = store["detergent"].category_id
    groups = api_client.get(f"{STATISTICS_URL}groups/", {**HERE, "category": cleaning}).json()
    assert (groups["level"], groups["category_name"]) == ("subcategory", "Limpieza")
    assert groups["groups"][-1] == {
        "id": None,
        "name": "Sin subcategoría",
        "units": 1.0,
        "revenue": 3.0,
        "profit": 1.0,
        "margin": 33.33,
    }

    ranking = api_client.get(
        f"{STATISTICS_URL}products/ranking/", {**HERE, "order_by": "margin", "min_units": "0"}
    ).json()
    assert ranking["order_by"] == "margin"
    assert [product["margin"] for product in ranking["results"]] == [50.0, 33.33, 16.67, -20.0]

    matrix = api_client.get(f"{STATISTICS_URL}matrix/", HERE).json()
    assert (matrix["median_units"], matrix["median_margin"]) == (6.0, 25.0)
    assert {"quadrant": "STAR", "count": 1} in matrix["counts"]
    assert len(matrix["products"]) == 4

    health = api_client.get(
        f"{STATISTICS_URL}inventory-health/", {**HERE, "max_days_left": 5}
    ).json()
    assert health["immobilized_capital_total"] == 12.0
    assert health["no_movement"][1]["last_sale_date"] is None
    assert [item["days_left"] for item in health["running_out"]] == [0.0]


def test_endpoints_validate_their_parameters(
    api_client: APIClient, manager: User, store: dict[str, Any]
) -> None:
    api_client.force_authenticate(manager)
    ranking_url = f"{STATISTICS_URL}products/ranking/"

    # Un MANAGER con varias sucursales debe decir cuál.
    assert api_client.get(f"{STATISTICS_URL}summary/").data["code"] == "branch_required"
    assert api_client.get(ranking_url, {**HERE, "limit": 101}).status_code == 400
    assert api_client.get(ranking_url, {**HERE, "order_by": "name"}).status_code == 400
    assert api_client.get(ranking_url, {**HERE, "limit": 100}).status_code == 200
    assert (
        api_client.get(f"{STATISTICS_URL}summary/", {**HERE, "date_from": "x"}).status_code == 400
    )
    unknown = api_client.get(f"{STATISTICS_URL}matrix/", {**HERE, "category": 999_999})
    assert (unknown.status_code, unknown.data["code"]) == (404, "category_not_found")


@pytest.mark.parametrize(
    "path",
    [
        "summary/",
        "credit-breakdown/",
        "groups/",
        "products/ranking/",
        "matrix/",
        "inventory-health/",
    ],
)
def test_statistics_are_only_for_managers(
    path: str, api_client: APIClient, supervisor: User
) -> None:
    assert api_client.get(f"{STATISTICS_URL}{path}").status_code == 401

    api_client.force_authenticate(supervisor)
    assert api_client.get(f"{STATISTICS_URL}{path}").status_code == 403
