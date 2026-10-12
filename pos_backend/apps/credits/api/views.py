"""Vistas de clientes, deudas y abonos. Sin lógica de negocio ni ORM."""

from typing import Any

from drf_spectacular.types import OpenApiTypes
from drf_spectacular.utils import OpenApiParameter, extend_schema
from rest_framework import status
from rest_framework.generics import GenericAPIView
from rest_framework.request import Request
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.credits.api.serializers import (
    CreditPaymentCreateSerializer,
    CreditPaymentSerializer,
    CreditQuerySerializer,
    CreditSerializer,
    CustomerCreateSerializer,
    CustomerQuerySerializer,
    CustomerSerializer,
    CustomerUpdateSerializer,
)
from apps.credits.domain.dtos import CreditPaymentInput
from apps.credits.services import credit_service, customer_service
from core.permissions import HasBranchAccess, IsSupervisorOrManager

BRANCH_PARAMETER = OpenApiParameter(
    "branch", OpenApiTypes.STR, description="Código de la sucursal de las deudas."
)


def _validated(serializer_class: type, data: Any) -> dict[str, Any]:
    serializer = serializer_class(data=data)
    serializer.is_valid(raise_exception=True)
    return serializer.validated_data


def _customer_context() -> dict[str, Any]:
    return {"payment_rate": credit_service.get_payment_rate()}


class CustomerListCreateView(GenericAPIView):
    permission_classes = [IsSupervisorOrManager, HasBranchAccess]
    serializer_class = CustomerSerializer
    filter_backends = []

    @extend_schema(
        operation_id="customers_list",
        parameters=[CustomerQuerySerializer],
        responses=CustomerSerializer(many=True),
        tags=["credits"],
    )
    def get(self, request: Request) -> Response:
        """Clientes ordenados por nombre, con lo que deben en la sucursal."""
        filters = _validated(CustomerQuerySerializer, request.query_params)
        customers = customer_service.list_customers(
            request.user,
            branch=filters.get("branch"),
            search=filters.get("search"),
            only_active=filters.get("active", False),
            with_debt=filters.get("with_debt", False),
        )
        page = self.paginate_queryset(customers)
        return self.get_paginated_response(
            CustomerSerializer(page, many=True, context=_customer_context()).data
        )

    @extend_schema(
        operation_id="customers_create",
        request=CustomerCreateSerializer,
        responses={201: CustomerSerializer},
        tags=["credits"],
    )
    def post(self, request: Request) -> Response:
        """Registra un cliente activo."""
        data = _validated(CustomerCreateSerializer, request.data)
        customer = customer_service.create_customer(user=request.user, **data)
        return Response(
            CustomerSerializer(customer, context=_customer_context()).data,
            status=status.HTTP_201_CREATED,
        )


class CustomerDetailView(APIView):
    permission_classes = [IsSupervisorOrManager, HasBranchAccess]

    @extend_schema(
        operation_id="customers_retrieve",
        parameters=[BRANCH_PARAMETER],
        responses=CustomerSerializer,
        tags=["credits"],
    )
    def get(self, request: Request, id: int) -> Response:
        customer = customer_service.get_customer(
            id, request.user, branch=request.query_params.get("branch")
        )
        return Response(CustomerSerializer(customer, context=_customer_context()).data)

    @extend_schema(
        operation_id="customers_partial_update",
        request=CustomerUpdateSerializer,
        responses=CustomerSerializer,
        tags=["credits"],
    )
    def patch(self, request: Request, id: int) -> Response:
        """Cambia los datos del cliente o lo activa/desactiva."""
        serializer = CustomerUpdateSerializer(data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        customer = customer_service.update_customer(id, request.user, **serializer.validated_data)
        return Response(CustomerSerializer(customer, context=_customer_context()).data)


class CustomerPaymentListCreateView(GenericAPIView):
    permission_classes = [IsSupervisorOrManager, HasBranchAccess]
    serializer_class = CreditPaymentSerializer
    filter_backends = []

    @extend_schema(
        operation_id="customers_payments_list",
        parameters=[BRANCH_PARAMETER],
        responses=CreditPaymentSerializer(many=True),
        tags=["credits"],
    )
    def get(self, request: Request, id: int) -> Response:
        """Abonos del cliente, del más reciente al más antiguo."""
        payments = credit_service.list_payments(
            id, request.user, branch=request.query_params.get("branch")
        )
        page = self.paginate_queryset(payments)
        return self.get_paginated_response(CreditPaymentSerializer(page, many=True).data)

    @extend_schema(
        operation_id="customers_payments_create",
        request=CreditPaymentCreateSerializer,
        responses={201: CreditPaymentSerializer},
        tags=["credits"],
    )
    def post(self, request: Request, id: int) -> Response:
        """Cobra un abono en la caja abierta del usuario.

        Los bolívares se pasan a USD con la tasa del BCV del día. El abono se
        reparte entre las deudas del cliente, la que vence antes primero.
        """
        data = _validated(CreditPaymentCreateSerializer, request.data)
        payment = credit_service.register_payment(
            CreditPaymentInput(customer_id=id, **data), request.user
        )
        return Response(CreditPaymentSerializer(payment).data, status=status.HTTP_201_CREATED)


class CreditListView(GenericAPIView):
    permission_classes = [IsSupervisorOrManager, HasBranchAccess]
    serializer_class = CreditSerializer
    filter_backends = []

    @extend_schema(
        operation_id="credits_list",
        parameters=[CreditQuerySerializer],
        responses=CreditSerializer(many=True),
        tags=["credits"],
    )
    def get(self, request: Request) -> Response:
        """Deudas de la sucursal, de la que vence antes a la que vence después."""
        filters = _validated(CreditQuerySerializer, request.query_params)
        credits = credit_service.list_credits(
            request.user,
            branch=filters.get("branch"),
            customer_id=filters.get("customer"),
            status=filters["status"],
        )
        page = self.paginate_queryset(credits)
        return self.get_paginated_response(CreditSerializer(page, many=True).data)
