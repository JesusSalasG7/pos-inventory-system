from rest_framework import serializers

from apps.auth.models import User

ASSIGNED_BRANCH_HELP = "Código de la sucursal; null = todas (solo MANAGER)."


class UserSerializer(serializers.ModelSerializer):
    assigned_branch = serializers.CharField(
        source="assigned_branch_id", read_only=True, allow_null=True
    )

    class Meta:
        model = User
        fields = ["id", "username", "full_name", "role", "assigned_branch", "is_active"]
        read_only_fields = fields


class UserCreateSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, min_length=8)
    # La existencia de la sucursal la valida user_service: el serializer no consulta la BD.
    assigned_branch = serializers.CharField(
        max_length=20, allow_null=True, help_text=ASSIGNED_BRANCH_HELP
    )

    class Meta:
        model = User
        fields = ["username", "password", "full_name", "role", "assigned_branch"]
        # La unicidad la valida user_service: el serializer no consulta la BD.
        extra_kwargs = {"username": {"validators": []}}


class UserUpdateSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, min_length=8, required=False)
    assigned_branch = serializers.CharField(
        max_length=20, allow_null=True, required=False, help_text=ASSIGNED_BRANCH_HELP
    )

    class Meta:
        model = User
        fields = ["full_name", "role", "assigned_branch", "is_active", "password"]
