"""Vistas de sucursales. Sin lógica de negocio ni ORM."""

from drf_spectacular.types import OpenApiTypes
from drf_spectacular.utils import OpenApiParameter, extend_schema
from rest_framework import status
from rest_framework.generics import GenericAPIView
from rest_framework.permissions import BasePermission
from rest_framework.request import Request
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.branches.api.serializers import (
    BranchCreateSerializer,
    BranchSerializer,
    BranchUpdateSerializer,
)
from apps.branches.services import branch_service
from core.permissions import IsManager, IsSupervisorOrManager
from core.query_params import is_true


class ReadSupervisorWriteManagerMixin:
    """Lectura para SUPERVISOR y MANAGER; escritura solo para MANAGER."""

    def get_permissions(self) -> list[BasePermission]:
        if self.request.method == "GET":
            return [IsSupervisorOrManager()]
        return [IsManager()]


class BranchListCreateView(ReadSupervisorWriteManagerMixin, GenericAPIView):
    serializer_class = BranchSerializer
    filter_backends = []

    @extend_schema(
        operation_id="branches_list",
        parameters=[
            OpenApiParameter("active", OpenApiTypes.BOOL, description="Solo sucursales activas.")
        ],
        responses=BranchSerializer(many=True),
        tags=["branches"],
    )
    def get(self, request: Request) -> Response:
        """Sucursales del negocio, ordenadas por nombre."""
        branches = branch_service.list_branches(
            only_active=is_true(request.query_params.get("active"))
        )
        page = self.paginate_queryset(branches)
        return self.get_paginated_response(BranchSerializer(page, many=True).data)

    @extend_schema(
        operation_id="branches_create",
        request=BranchCreateSerializer,
        responses={201: BranchSerializer},
        tags=["branches"],
    )
    def post(self, request: Request) -> Response:
        """Crea una sucursal con stock cero de todos los productos."""
        serializer = BranchCreateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        branch = branch_service.create_branch(**serializer.validated_data)
        return Response(BranchSerializer(branch).data, status=status.HTTP_201_CREATED)


class BranchDetailView(ReadSupervisorWriteManagerMixin, APIView):
    @extend_schema(operation_id="branches_retrieve", responses=BranchSerializer, tags=["branches"])
    def get(self, request: Request, code: str) -> Response:
        return Response(BranchSerializer(branch_service.get_branch(code)).data)

    @extend_schema(
        operation_id="branches_partial_update",
        request=BranchUpdateSerializer,
        responses=BranchSerializer,
        tags=["branches"],
    )
    def patch(self, request: Request, code: str) -> Response:
        """Cambia el nombre o activa/desactiva la sucursal. El código no cambia."""
        serializer = BranchUpdateSerializer(data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        branch = branch_service.update_branch(code, **serializer.validated_data)
        return Response(BranchSerializer(branch).data)
