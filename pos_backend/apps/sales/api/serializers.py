from rest_framework import serializers

from apps.sales.models import Sale, SaleDetail, SalePayment
from core.enums import Currency, PaymentMethod


class SaleItemInputSerializer(serializers.Serializer):
    """El cliente nunca envía el precio: se toma de la base de datos."""

    product_id = serializers.IntegerField(min_value=1)
    quantity = serializers.DecimalField(max_digits=12, decimal_places=3, min_value=0)


class PaymentInputSerializer(serializers.Serializer):
    method = serializers.ChoiceField(choices=PaymentMethod.choices)
    currency = serializers.ChoiceField(choices=Currency.choices)
    amount = serializers.DecimalField(max_digits=14, decimal_places=2, min_value=0)
    approval_reference = serializers.CharField(max_length=50, required=False, allow_blank=True)


class CreateSaleSerializer(serializers.Serializer):
    branch = serializers.CharField(max_length=20, required=False)
    customer_tax_id = serializers.CharField(max_length=20, required=False, allow_blank=True)
    customer_name = serializers.CharField(max_length=150, required=False, allow_blank=True)
    items = SaleItemInputSerializer(many=True, allow_empty=False)
    payments = PaymentInputSerializer(many=True, allow_empty=False)


class SaleDetailSerializer(serializers.ModelSerializer):
    class Meta:
        model = SaleDetail
        fields = ["id", "product", "quantity", "unit_price_usd", "subtotal_usd", "subtotal_ves"]
        read_only_fields = fields


class SalePaymentSerializer(serializers.ModelSerializer):
    class Meta:
        model = SalePayment
        fields = ["id", "method", "currency", "amount", "approval_reference"]
        read_only_fields = fields


class SaleSerializer(serializers.ModelSerializer):
    details = SaleDetailSerializer(many=True, read_only=True)
    payments = SalePaymentSerializer(many=True, read_only=True)
    branch = serializers.CharField(source="branch_id", read_only=True)

    class Meta:
        model = Sale
        fields = [
            "id",
            "cash_session",
            "user",
            "branch",
            "customer_tax_id",
            "customer_name",
            "exchange_rate_at_invoice",
            "total_usd",
            "total_ves",
            "created_at",
            "details",
            "payments",
        ]
        read_only_fields = fields


class SalesSummarySerializer(serializers.Serializer):
    sales_count = serializers.IntegerField()
    total_usd = serializers.DecimalField(max_digits=14, decimal_places=2)
    total_ves = serializers.DecimalField(max_digits=14, decimal_places=2)


class SalesQuerySerializer(serializers.Serializer):
    """Filtros de query string del listado y del reporte de ventas."""

    branch = serializers.CharField(max_length=20, required=False)
    cash_session = serializers.IntegerField(min_value=1, required=False)
    date_from = serializers.DateTimeField(required=False)
    date_to = serializers.DateTimeField(required=False)
