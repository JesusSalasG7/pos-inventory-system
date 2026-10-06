"""Vistas de cajas, egresos y arqueo. Sin lógica de negocio ni ORM."""

from dataclasses import asdict

from drf_spectacular.types import OpenApiTypes
from drf_spectacular.utils import OpenApiParameter, extend_schema
from rest_framework import status
from rest_framework.generics import GenericAPIView
from rest_framework.request import Request
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.cash_sessions.api.serializers import (
    CashCountSummarySerializer,
    CashExpenseSerializer,
    CashSessionSerializer,
    CloseCashSessionSerializer,
    OpenCashSessionSerializer,
)
from apps.cash_sessions.services import cash_count_service, cash_session_service
from core.permissions import HasBranchAccess, IsSupervisorOrManager
from core.query_params import is_true


class CashSessionListCreateView(GenericAPIView):
    permission_classes = [IsSupervisorOrManager, HasBranchAccess]
    serializer_class = CashSessionSerializer
    filter_backends = []

    @extend_schema(
        operation_id="cash_sessions_list",
        parameters=[
            OpenApiParameter("branch", OpenApiTypes.STR, description="Código de la sucursal."),
            OpenApiParameter("only_open", OpenApiTypes.BOOL),
        ],
        responses=CashSessionSerializer(many=True),
        tags=["cash-sessions"],
    )
    def get(self, request: Request) -> Response:
        """Lista las cajas de la sucursal, de la más reciente a la más antigua."""
        sessions = cash_session_service.list_sessions(
            request.user,
            branch=request.query_params.get("branch"),
            only_open=is_true(request.query_params.get("only_open")),
        )
        page = self.paginate_queryset(sessions)
        return self.get_paginated_response(CashSessionSerializer(page, many=True).data)

    @extend_schema(
        operation_id="cash_sessions_open",
        request=OpenCashSessionSerializer,
        responses={201: CashSessionSerializer},
        tags=["cash-sessions"],
    )
    def post(self, request: Request) -> Response:
        """Abre una caja para el usuario autenticado."""
        serializer = OpenCashSessionSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        session = cash_session_service.open_session(
            user=request.user,
            branch=serializer.validated_data.get("branch"),
            opening_float=serializer.validated_data["opening_float"],
        )
        return Response(CashSessionSerializer(session).data, status=status.HTTP_201_CREATED)


class CurrentCashSessionView(APIView):
    permission_classes = [IsSupervisorOrManager]

    @extend_schema(
        operation_id="cash_sessions_current",
        responses=CashSessionSerializer,
        tags=["cash-sessions"],
    )
    def get(self, request: Request) -> Response:
        """Caja abierta del usuario. Responde 409 `no_open_session` si no tiene."""
        session = cash_session_service.get_open_session(request.user)
        return Response(CashSessionSerializer(session).data)


class CashExpenseListCreateView(GenericAPIView):
    permission_classes = [IsSupervisorOrManager, HasBranchAccess]
    serializer_class = CashExpenseSerializer
    filter_backends = []

    @extend_schema(
        operation_id="cash_sessions_expenses_list",
        responses=CashExpenseSerializer(many=True),
        tags=["cash-sessions"],
    )
    def get(self, request: Request, id: int) -> Response:
        """Lista los egresos de la caja."""
        page = self.paginate_queryset(cash_session_service.list_expenses(id, request.user))
        return self.get_paginated_response(CashExpenseSerializer(page, many=True).data)

    @extend_schema(
        operation_id="cash_sessions_expenses_create",
        request=CashExpenseSerializer,
        responses={201: CashExpenseSerializer},
        tags=["cash-sessions"],
    )
    def post(self, request: Request, id: int) -> Response:
        """Registra un egreso de efectivo en una caja abierta."""
        serializer = CashExpenseSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        expense = cash_session_service.register_expense(
            session_id=id, user=request.user, **serializer.validated_data
        )
        return Response(CashExpenseSerializer(expense).data, status=status.HTTP_201_CREATED)


class CashSessionSummaryView(APIView):
    permission_classes = [IsSupervisorOrManager, HasBranchAccess]

    @extend_schema(
        operation_id="cash_sessions_summary",
        responses=CashCountSummarySerializer,
        tags=["cash-sessions"],
    )
    def get(self, request: Request, id: int) -> Response:
        """Arqueo: efectivo esperado en la caja según ventas y egresos."""
        session = cash_session_service.get_session(id, request.user)
        summary = cash_count_service.build_summary(session)
        return Response(CashCountSummarySerializer(asdict(summary)).data)


class CashSessionCloseView(APIView):
    permission_classes = [IsSupervisorOrManager, HasBranchAccess]

    @extend_schema(
        operation_id="cash_sessions_close",
        request=CloseCashSessionSerializer,
        responses=CashSessionSerializer,
        tags=["cash-sessions"],
    )
    def post(self, request: Request, id: int) -> Response:
        """Cierra la caja con los montos contados y calcula la diferencia."""
        serializer = CloseCashSessionSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        session = cash_session_service.close_session(
            session_id=id, user=request.user, **serializer.validated_data
        )
        return Response(CashSessionSerializer(session).data)
