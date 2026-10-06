from rest_framework import serializers

from apps.branches.models import Branch


class BranchSerializer(serializers.ModelSerializer):
    class Meta:
        model = Branch
        fields = ["code", "name", "active"]
        read_only_fields = fields


class BranchCreateSerializer(serializers.Serializer):
    code = serializers.CharField(
        max_length=20, help_text="Identificador estable, p. ej. `CENTRO`. No se puede cambiar."
    )
    name = serializers.CharField(max_length=100)


class BranchUpdateSerializer(serializers.Serializer):
    name = serializers.CharField(max_length=100, required=False)
    active = serializers.BooleanField(required=False)
