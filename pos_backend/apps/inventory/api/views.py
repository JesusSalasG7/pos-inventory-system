"""Vistas de catálogo, inventario y Kardex. Sin lógica de negocio ni ORM."""

from django.db.models import QuerySet
from django_filters.rest_framework import DjangoFilterBackend
from drf_spectacular.types import OpenApiTypes
from drf_spectacular.utils import OpenApiParameter, extend_schema
from rest_framework import status
from rest_framework.generics import GenericAPIView
from rest_framework.permissions import BasePermission
from rest_framework.request import Request
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.inventory.api.filters import InventoryMovementFilter
from apps.inventory.api.serializers import (
    BranchInventorySerializer,
    CategoryCreateSerializer,
    CategorySerializer,
    CategoryUpdateSerializer,
    InventoryMovementCreateSerializer,
    InventoryMovementSerializer,
    MinimumStockSerializer,
    ProductListQuerySerializer,
    ProductSerializer,
)
from apps.inventory.models import InventoryMovement
from apps.inventory.services import category_service, product_service, stock_service
from core.branch_scope import resolve_branch
from core.permissions import HasBranchAccess, IsManager, IsSupervisorOrManager
from core.query_params import is_true

BRANCH_PARAMETER = OpenApiParameter(
    "branch",
    OpenApiTypes.STR,
    description="Código de la sucursal. Por defecto, la asignada al usuario.",
)


class ReadSupervisorWriteManagerMixin:
    """Lectura para SUPERVISOR y MANAGER; escritura solo para MANAGER."""

    def get_permissions(self) -> list[BasePermission]:
        if self.request.method == "GET":
            return [IsSupervisorOrManager()]
        return [IsManager()]


class CategoryListCreateView(ReadSupervisorWriteManagerMixin, GenericAPIView):
    serializer_class = CategorySerializer
    filter_backends = []

    @extend_schema(
        operation_id="categories_list",
        parameters=[
            OpenApiParameter("active", OpenApiTypes.BOOL, description="Solo categorías activas.")
        ],
        responses=CategorySerializer(many=True),
        tags=["categories"],
    )
    def get(self, request: Request) -> Response:
        """Categorías del catálogo, ordenadas por nombre."""
        categories = category_service.list_categories(
            only_active=is_true(request.query_params.get("active"))
        )
        page = self.paginate_queryset(categories)
        return self.get_paginated_response(CategorySerializer(page, many=True).data)

    @extend_schema(
        operation_id="categories_create",
        request=CategoryCreateSerializer,
        responses={201: CategorySerializer},
        tags=["categories"],
    )
    def post(self, request: Request) -> Response:
        """Crea una categoría activa."""
        serializer = CategoryCreateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        category = category_service.create_category(**serializer.validated_data)
        return Response(CategorySerializer(category).data, status=status.HTTP_201_CREATED)


class CategoryDetailView(ReadSupervisorWriteManagerMixin, APIView):
    @extend_schema(
        operation_id="categories_retrieve", responses=CategorySerializer, tags=["categories"]
    )
    def get(self, request: Request, id: int) -> Response:
        return Response(CategorySerializer(category_service.get_category(id)).data)

    @extend_schema(
        operation_id="categories_partial_update",
        request=CategoryUpdateSerializer,
        responses=CategorySerializer,
        tags=["categories"],
    )
    def patch(self, request: Request, id: int) -> Response:
        """Cambia el nombre o activa/desactiva la categoría."""
        serializer = CategoryUpdateSerializer(data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        category = category_service.update_category(id, **serializer.validated_data)
        return Response(CategorySerializer(category).data)


class ProductListCreateView(ReadSupervisorWriteManagerMixin, GenericAPIView):
    serializer_class = ProductSerializer
    filter_backends = []

    @extend_schema(
        operation_id="products_list",
        parameters=[
            OpenApiParameter("active", OpenApiTypes.BOOL, description="Solo productos activos."),
            OpenApiParameter("category", OpenApiTypes.INT, description="Id de la categoría."),
            OpenApiParameter("search", OpenApiTypes.STR, description="Texto dentro del nombre."),
        ],
        responses=ProductSerializer(many=True),
        tags=["products"],
    )
    def get(self, request: Request) -> Response:
        """Catálogo de productos, ordenado por nombre."""
        params = request.query_params
        query = ProductListQuerySerializer(data=params)
        query.is_valid(raise_exception=True)
        products = product_service.list_products(
            only_active=is_true(params.get("active")),
            category_id=query.validated_data.get("category"),
            search=params.get("search"),
        )
        page = self.paginate_queryset(products)
        return self.get_paginated_response(ProductSerializer(page, many=True).data)

    @extend_schema(
        operation_id="products_create",
        request=ProductSerializer,
        responses={201: ProductSerializer},
        tags=["products"],
    )
    def post(self, request: Request) -> Response:
        """Crea un producto con stock cero en todas las sucursales activas."""
        serializer = ProductSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        product = product_service.create_product(**serializer.validated_data)
        return Response(ProductSerializer(product).data, status=status.HTTP_201_CREATED)


class ProductDetailView(ReadSupervisorWriteManagerMixin, APIView):
    @extend_schema(operation_id="products_retrieve", responses=ProductSerializer, tags=["products"])
    def get(self, request: Request, id: int) -> Response:
        return Response(ProductSerializer(product_service.get_product(id)).data)

    @extend_schema(
        operation_id="products_partial_update",
        request=ProductSerializer,
        responses=ProductSerializer,
        tags=["products"],
    )
    def patch(self, request: Request, id: int) -> Response:
        """Actualiza los campos enviados. No afecta a ventas ya facturadas."""
        serializer = ProductSerializer(data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        product = product_service.update_product(id, **serializer.validated_data)
        return Response(ProductSerializer(product).data)


class ProductToggleActiveView(APIView):
    permission_classes = [IsManager]

    @extend_schema(
        operation_id="products_toggle_active",
        request=None,
        responses=ProductSerializer,
        tags=["products"],
    )
    def post(self, request: Request, id: int) -> Response:
        """Activa o desactiva el producto."""
        return Response(ProductSerializer(product_service.toggle_active(id)).data)


class BranchInventoryListView(GenericAPIView):
    permission_classes = [IsSupervisorOrManager, HasBranchAccess]
    serializer_class = BranchInventorySerializer
    filter_backends = []

    @extend_schema(
        operation_id="inventory_list",
        parameters=[BRANCH_PARAMETER],
        responses=BranchInventorySerializer(many=True),
        tags=["inventory"],
    )
    def get(self, request: Request) -> Response:
        """Existencias de la sucursal."""
        branch = resolve_branch(request.user, request.query_params.get("branch"))
        page = self.paginate_queryset(stock_service.get_branch_inventory(branch))
        return self.get_paginated_response(BranchInventorySerializer(page, many=True).data)


class LowStockListView(GenericAPIView):
    permission_classes = [IsSupervisorOrManager, HasBranchAccess]
    serializer_class = BranchInventorySerializer
    filter_backends = []

    @extend_schema(
        operation_id="inventory_low_stock",
        parameters=[BRANCH_PARAMETER],
        responses=BranchInventorySerializer(many=True),
        tags=["inventory"],
    )
    def get(self, request: Request) -> Response:
        """Productos activos con stock en o por debajo del mínimo."""
        branch = resolve_branch(request.user, request.query_params.get("branch"))
        page = self.paginate_queryset(stock_service.get_low_stock(branch))
        return self.get_paginated_response(BranchInventorySerializer(page, many=True).data)


class MinimumStockView(APIView):
    permission_classes = [IsManager, HasBranchAccess]

    @extend_schema(
        operation_id="inventory_set_minimum_stock",
        request=MinimumStockSerializer,
        responses=BranchInventorySerializer,
        tags=["inventory"],
    )
    def patch(self, request: Request, product_id: int) -> Response:
        """Define el stock mínimo del producto en la sucursal."""
        serializer = MinimumStockSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        branch = resolve_branch(request.user, serializer.validated_data.get("branch"))
        inventory = stock_service.set_minimum_stock(
            branch, product_id, serializer.validated_data["minimum_stock"]
        )
        return Response(BranchInventorySerializer(inventory).data)


class InventoryMovementListCreateView(GenericAPIView):
    permission_classes = [IsSupervisorOrManager, HasBranchAccess]
    serializer_class = InventoryMovementSerializer
    filter_backends = [DjangoFilterBackend]
    filterset_class = InventoryMovementFilter

    def get_queryset(self) -> QuerySet[InventoryMovement]:
        if getattr(self, "swagger_fake_view", False):
            # Al generar el esquema OpenAPI no hay usuario; drf-spectacular solo
            # necesita el modelo del queryset para documentar los filtros.
            return stock_service.list_movements("")
        branch = resolve_branch(self.request.user, self.request.query_params.get("branch"))
        return stock_service.list_movements(branch)

    @extend_schema(
        operation_id="inventory_movements_list",
        responses=InventoryMovementSerializer(many=True),
        tags=["inventory"],
    )
    def get(self, request: Request) -> Response:
        """Kardex de la sucursal, del movimiento más reciente al más antiguo."""
        page = self.paginate_queryset(self.filter_queryset(self.get_queryset()))
        return self.get_paginated_response(InventoryMovementSerializer(page, many=True).data)

    @extend_schema(
        operation_id="inventory_movements_create",
        request=InventoryMovementCreateSerializer,
        responses={201: InventoryMovementSerializer, 204: None},
        tags=["inventory"],
    )
    def post(self, request: Request) -> Response:
        """Registra una entrada, merma o ajuste.

        Responde 204 si un ajuste coincide con el stock actual y no cambia nada.
        """
        serializer = InventoryMovementCreateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data
        movement = stock_service.register_manual_movement(
            movement_type=data["movement_type"],
            branch=resolve_branch(request.user, data.get("branch")),
            product_id=data["product_id"],
            quantity=data["quantity"],
            user=request.user,
            notes=data.get("notes", ""),
        )
        if movement is None:
            return Response(status=status.HTTP_204_NO_CONTENT)
        return Response(InventoryMovementSerializer(movement).data, status=status.HTTP_201_CREATED)
