"""Vistas de autenticación y usuarios. Sin lógica de negocio ni ORM."""

from drf_spectacular.types import OpenApiTypes
from drf_spectacular.utils import OpenApiParameter, extend_schema
from rest_framework import status
from rest_framework.generics import GenericAPIView
from rest_framework.permissions import IsAuthenticated
from rest_framework.request import Request
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.auth.api.serializers import UserCreateSerializer, UserSerializer, UserUpdateSerializer
from apps.auth.services import user_service
from core.permissions import IsManager
from core.query_params import is_true


class MeView(APIView):
    permission_classes = [IsAuthenticated]

    @extend_schema(operation_id="auth_me", responses=UserSerializer, tags=["auth"])
    def get(self, request: Request) -> Response:
        """Devuelve el usuario autenticado."""
        return Response(UserSerializer(request.user).data)


class UserListCreateView(GenericAPIView):
    permission_classes = [IsManager]
    serializer_class = UserSerializer
    filter_backends = []

    @extend_schema(
        operation_id="users_list",
        parameters=[
            OpenApiParameter("active", OpenApiTypes.BOOL, description="Solo usuarios activos.")
        ],
        responses=UserSerializer(many=True),
        tags=["users"],
    )
    def get(self, request: Request) -> Response:
        """Usuarios del sistema, ordenados por nombre de usuario."""
        users = user_service.list_users(only_active=is_true(request.query_params.get("active")))
        page = self.paginate_queryset(users)
        return self.get_paginated_response(UserSerializer(page, many=True).data)

    @extend_schema(
        operation_id="users_create",
        request=UserCreateSerializer,
        responses={201: UserSerializer},
        tags=["users"],
    )
    def post(self, request: Request) -> Response:
        """Crea un usuario con su contraseña inicial."""
        serializer = UserCreateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = user_service.create_user(**serializer.validated_data)
        return Response(UserSerializer(user).data, status=status.HTTP_201_CREATED)


class UserDetailView(APIView):
    permission_classes = [IsManager]

    @extend_schema(operation_id="users_retrieve", responses=UserSerializer, tags=["users"])
    def get(self, request: Request, id: int) -> Response:
        return Response(UserSerializer(user_service.get_user(id)).data)

    @extend_schema(
        operation_id="users_partial_update",
        request=UserUpdateSerializer,
        responses=UserSerializer,
        tags=["users"],
    )
    def patch(self, request: Request, id: int) -> Response:
        """Actualiza los campos enviados; con `password` asigna una contraseña nueva."""
        serializer = UserUpdateSerializer(data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        user = user_service.update_user(id, request.user, **serializer.validated_data)
        return Response(UserSerializer(user).data)
