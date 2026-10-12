"""Vistas de las estadísticas. Sin lógica de negocio ni ORM."""

from typing import Any

from drf_spectacular.utils import extend_schema
from rest_framework import serializers
from rest_framework.request import Request
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.statistics.api.serializers import (
    CreditBreakdownSerializer,
    GroupReportSerializer,
    InventoryHealthQuerySerializer,
    InventoryHealthSerializer,
    MatrixSerializer,
    ProductRankingSerializer,
    RankingQuerySerializer,
    StatisticsFilterSerializer,
    SummarySerializer,
)
from apps.statistics.domain.dtos import StatisticsFilters
from apps.statistics.services import statistics_service
from core.branch_scope import resolve_branch
from core.permissions import HasBranchAccess, IsManager


class StatisticsView(APIView):
    """Base de los endpoints: solo MANAGER, acotados a una sucursal."""

    permission_classes = [IsManager, HasBranchAccess]
    query_serializer_class: type[serializers.Serializer] = StatisticsFilterSerializer

    def read_query(self, request: Request) -> tuple[StatisticsFilters, dict[str, Any]]:
        """Devuelve los filtros globales y el resto de parámetros ya validados."""
        serializer = self.query_serializer_class(data=request.query_params)
        serializer.is_valid(raise_exception=True)
        params = dict(serializer.validated_data)
        filters = StatisticsFilters(
            branch=resolve_branch(request.user, params.pop("branch", None)),
            date_from=params.pop("date_from", None),
            date_to=params.pop("date_to", None),
            category_id=params.pop("category", None),
            subcategory_id=params.pop("subcategory", None),
        )
        return filters, params


class SummaryView(StatisticsView):
    @extend_schema(
        operation_id="statistics_summary",
        parameters=[StatisticsFilterSerializer],
        responses=SummarySerializer,
        tags=["statistics"],
    )
    def get(self, request: Request) -> Response:
        """KPIs del período y del anterior, con la variación de cada uno."""
        filters, _ = self.read_query(request)
        return Response(SummarySerializer(statistics_service.get_summary(filters)).data)


class CreditBreakdownView(StatisticsView):
    @extend_schema(
        operation_id="statistics_credit_breakdown",
        parameters=[StatisticsFilterSerializer],
        responses=CreditBreakdownSerializer,
        tags=["statistics"],
    )
    def get(self, request: Request) -> Response:
        """Ingresos y ganancia del período repartidos entre contado y crédito."""
        filters, _ = self.read_query(request)
        breakdown = statistics_service.get_credit_breakdown(filters)
        return Response(CreditBreakdownSerializer(breakdown).data)


class GroupPerformanceView(StatisticsView):
    @extend_schema(
        operation_id="statistics_groups",
        parameters=[StatisticsFilterSerializer],
        responses=GroupReportSerializer,
        tags=["statistics"],
    )
    def get(self, request: Request) -> Response:
        """Rendimiento por categoría o, con `category`, por sus subcategorías."""
        filters, _ = self.read_query(request)
        report = statistics_service.get_group_performance(filters)
        return Response(GroupReportSerializer(report).data)


class ProductRankingView(StatisticsView):
    query_serializer_class = RankingQuerySerializer

    @extend_schema(
        operation_id="statistics_product_ranking",
        parameters=[RankingQuerySerializer],
        responses=ProductRankingSerializer,
        tags=["statistics"],
    )
    def get(self, request: Request) -> Response:
        """Ranking de productos por unidades, ingresos, ganancia o margen."""
        filters, params = self.read_query(request)
        ranking = statistics_service.get_product_ranking(filters, **params)
        return Response(ProductRankingSerializer(ranking).data)


class MatrixView(StatisticsView):
    @extend_schema(
        operation_id="statistics_matrix",
        parameters=[StatisticsFilterSerializer],
        responses=MatrixSerializer,
        tags=["statistics"],
    )
    def get(self, request: Request) -> Response:
        """Matriz volumen vs. margen, con cortes en las medianas."""
        filters, _ = self.read_query(request)
        return Response(MatrixSerializer(statistics_service.get_matrix(filters)).data)


class InventoryHealthView(StatisticsView):
    query_serializer_class = InventoryHealthQuerySerializer

    @extend_schema(
        operation_id="statistics_inventory_health",
        parameters=[InventoryHealthQuerySerializer],
        responses=InventoryHealthSerializer,
        tags=["statistics"],
    )
    def get(self, request: Request) -> Response:
        """Productos sin movimiento y por agotarse, a la fecha de hoy."""
        filters, params = self.read_query(request)
        health = statistics_service.get_inventory_health(filters, **params)
        return Response(InventoryHealthSerializer(health).data)
