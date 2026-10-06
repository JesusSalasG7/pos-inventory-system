"""Vistas de ventas y reportes. Sin lógica de negocio ni ORM."""

from typing import Any

from drf_spectacular.utils import extend_schema
from rest_framework import status
from rest_framework.generics import GenericAPIView
from rest_framework.request import Request
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.sales.api.serializers import (
    CreateSaleSerializer,
    SaleSerializer,
    SalesQuerySerializer,
    SalesSummarySerializer,
)
from apps.sales.domain.dtos import CreateSaleInput, PaymentInput, SaleItemInput
from apps.sales.services import sale_service
from core.permissions import HasBranchAccess, IsSupervisorOrManager


def _query_filters(request: Request) -> dict[str, Any]:
    serializer = SalesQuerySerializer(data=request.query_params)
    serializer.is_valid(raise_exception=True)
    return serializer.validated_data


class SaleListCreateView(GenericAPIView):
    permission_classes = [IsSupervisorOrManager, HasBranchAccess]
    serializer_class = SaleSerializer
    filter_backends = []

    @extend_schema(
        operation_id="sales_list",
        parameters=[SalesQuerySerializer],
        responses=SaleSerializer(many=True),
        tags=["sales"],
    )
    def get(self, request: Request) -> Response:
        """Ventas de la sucursal, de la más reciente a la más antigua."""
        filters = _query_filters(request)
        sales = sale_service.list_sales(
            request.user,
            branch=filters.get("branch"),
            cash_session_id=filters.get("cash_session"),
            date_from=filters.get("date_from"),
            date_to=filters.get("date_to"),
        )
        page = self.paginate_queryset(sales)
        return self.get_paginated_response(SaleSerializer(page, many=True).data)

    @extend_schema(
        operation_id="sales_create",
        request=CreateSaleSerializer,
        responses={201: SaleSerializer},
        tags=["sales"],
    )
    def post(self, request: Request) -> Response:
        """Registra una venta en la caja abierta del usuario.

        Los precios se toman de la base de datos y la tasa activa queda
        congelada en la venta.
        """
        serializer = CreateSaleSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data
        sale_input = CreateSaleInput(
            items=tuple(SaleItemInput(**item) for item in data["items"]),
            payments=tuple(PaymentInput(**payment) for payment in data["payments"]),
            branch=data.get("branch"),
            customer_tax_id=data.get("customer_tax_id", ""),
            customer_name=data.get("customer_name", ""),
        )
        sale = sale_service.create_sale(sale_input, request.user)
        return Response(SaleSerializer(sale).data, status=status.HTTP_201_CREATED)


class SaleDetailView(APIView):
    permission_classes = [IsSupervisorOrManager, HasBranchAccess]

    @extend_schema(operation_id="sales_retrieve", responses=SaleSerializer, tags=["sales"])
    def get(self, request: Request, id: int) -> Response:
        return Response(SaleSerializer(sale_service.get_sale(id, request.user)).data)


class SalesSummaryReportView(APIView):
    permission_classes = [IsSupervisorOrManager, HasBranchAccess]

    @extend_schema(
        operation_id="sales_reports_summary",
        parameters=[SalesQuerySerializer],
        responses=SalesSummarySerializer,
        tags=["sales"],
    )
    def get(self, request: Request) -> Response:
        """Número de ventas y totales en USD y VES del periodo."""
        filters = _query_filters(request)
        summary = sale_service.get_sales_summary(
            request.user,
            branch=filters.get("branch"),
            date_from=filters.get("date_from"),
            date_to=filters.get("date_to"),
        )
        return Response(SalesSummarySerializer(summary).data)
