"""Vistas de la tasa de cambio. Sin lógica de negocio ni ORM."""

from drf_spectacular.utils import extend_schema
from rest_framework import status
from rest_framework.generics import GenericAPIView
from rest_framework.permissions import BasePermission
from rest_framework.request import Request
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.exchange_rate.api.serializers import BcvRateSerializer, ExchangeRateSerializer
from apps.exchange_rate.services import bcv_rate_service, exchange_rate_service
from core.permissions import IsManager, IsSupervisorOrManager


class ExchangeRateListCreateView(GenericAPIView):
    serializer_class = ExchangeRateSerializer
    filter_backends = []

    def get_permissions(self) -> list[BasePermission]:
        # Cualquier operador consulta el histórico; solo el MANAGER fija la tasa.
        if self.request.method == "GET":
            return [IsSupervisorOrManager()]
        return [IsManager()]

    @extend_schema(
        operation_id="exchange_rates_list",
        responses=ExchangeRateSerializer(many=True),
        tags=["exchange-rates"],
    )
    def get(self, request: Request) -> Response:
        """Histórico de tasas, de la más reciente a la más antigua."""
        page = self.paginate_queryset(exchange_rate_service.list_rates())
        return self.get_paginated_response(ExchangeRateSerializer(page, many=True).data)

    @extend_schema(
        operation_id="exchange_rates_create",
        request=ExchangeRateSerializer,
        responses={201: ExchangeRateSerializer},
        tags=["exchange-rates"],
    )
    def post(self, request: Request) -> Response:
        """Registra una nueva tasa, que pasa a ser la activa."""
        serializer = ExchangeRateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        rate = exchange_rate_service.register_rate(
            usd_to_ves_rate=serializer.validated_data["usd_to_ves_rate"], user=request.user
        )
        return Response(ExchangeRateSerializer(rate).data, status=status.HTTP_201_CREATED)


class CurrentExchangeRateView(APIView):
    permission_classes = [IsSupervisorOrManager]

    @extend_schema(
        operation_id="exchange_rates_current",
        responses=ExchangeRateSerializer,
        tags=["exchange-rates"],
    )
    def get(self, request: Request) -> Response:
        """Tasa activa. Responde 409 `exchange_rate_not_set` si no hay ninguna."""
        return Response(ExchangeRateSerializer(exchange_rate_service.get_active_rate()).data)


class BcvRateView(APIView):
    permission_classes = [IsSupervisorOrManager]

    @extend_schema(
        operation_id="exchange_rates_bcv",
        responses=BcvRateSerializer,
        tags=["exchange-rates"],
    )
    def get(self, request: Request) -> Response:
        """Tasa oficial del BCV, solo como referencia: no cambia la tasa activa.

        Responde 503 `bcv_rate_unavailable` si la fuente externa no responde.
        """
        return Response(BcvRateSerializer(bcv_rate_service.get_bcv_rate_or_fail()).data)
