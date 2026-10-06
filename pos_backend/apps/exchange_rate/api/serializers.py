from rest_framework import serializers

from apps.exchange_rate.models import ExchangeRate


class ExchangeRateSerializer(serializers.ModelSerializer):
    class Meta:
        model = ExchangeRate
        fields = ["id", "usd_to_ves_rate", "created_by", "created_at"]
        read_only_fields = ["id", "created_by", "created_at"]


class BcvRateSerializer(serializers.Serializer):
    """Tasa oficial del BCV obtenida de la fuente externa (solo lectura)."""

    rate = serializers.DecimalField(max_digits=14, decimal_places=4, read_only=True)
    updated_at = serializers.DateTimeField(read_only=True)
