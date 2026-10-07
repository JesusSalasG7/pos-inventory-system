from rest_framework import serializers

from apps.cash_sessions.models import CashExpense, CashSession
from core.enums import Currency, PaymentMethod


class CashSessionSerializer(serializers.ModelSerializer):
    branch = serializers.CharField(source="branch_id", read_only=True)

    class Meta:
        model = CashSession
        fields = [
            "id",
            "user",
            "branch",
            "opened_at",
            "closed_at",
            "opening_float",
            "counted_amount_usd",
            "counted_amount_ves",
            "difference_usd",
        ]
        read_only_fields = fields


class OpenCashSessionSerializer(serializers.Serializer):
    branch = serializers.CharField(max_length=20, required=False)
    opening_float = serializers.DecimalField(max_digits=14, decimal_places=2, min_value=0)


class CloseCashSessionSerializer(serializers.Serializer):
    counted_amount_usd = serializers.DecimalField(max_digits=14, decimal_places=2, min_value=0)
    counted_amount_ves = serializers.DecimalField(max_digits=14, decimal_places=2, min_value=0)


class CashExpenseSerializer(serializers.ModelSerializer):
    class Meta:
        model = CashExpense
        fields = ["id", "cash_session", "reason", "amount", "currency", "created_by", "created_at"]
        read_only_fields = ["id", "cash_session", "created_by", "created_at"]


class CashCountSummarySerializer(serializers.Serializer):
    opening_float = serializers.DecimalField(max_digits=14, decimal_places=2)
    cash_sales_usd = serializers.DecimalField(max_digits=14, decimal_places=2)
    cash_sales_ves = serializers.DecimalField(max_digits=14, decimal_places=2)
    electronic_sales_usd = serializers.DecimalField(max_digits=14, decimal_places=2)
    electronic_sales_ves = serializers.DecimalField(max_digits=14, decimal_places=2)
    expenses_usd = serializers.DecimalField(max_digits=14, decimal_places=2)
    expenses_ves = serializers.DecimalField(max_digits=14, decimal_places=2)
    expected_cash_usd = serializers.DecimalField(max_digits=14, decimal_places=2)
    expected_cash_ves = serializers.DecimalField(max_digits=14, decimal_places=2)


class PaymentTotalSerializer(serializers.Serializer):
    method = serializers.ChoiceField(choices=PaymentMethod.choices)
    currency = serializers.ChoiceField(choices=Currency.choices)
    amount = serializers.DecimalField(max_digits=14, decimal_places=2)


class ProductSalesSerializer(serializers.Serializer):
    product = serializers.IntegerField(source="product_id")
    product_name = serializers.CharField()
    quantity = serializers.DecimalField(max_digits=12, decimal_places=3)
    sales_usd = serializers.DecimalField(max_digits=14, decimal_places=2)
    sales_ves = serializers.DecimalField(max_digits=14, decimal_places=2)
    cost_usd = serializers.DecimalField(max_digits=14, decimal_places=2)
    cost_ves = serializers.DecimalField(max_digits=14, decimal_places=2)
    profit_usd = serializers.DecimalField(max_digits=14, decimal_places=2)
    profit_ves = serializers.DecimalField(max_digits=14, decimal_places=2)


class SessionSalesReportSerializer(serializers.Serializer):
    """Lo vendido en una caja. Los bolívares usan la tasa congelada de cada venta."""

    sales_count = serializers.IntegerField()
    total_usd = serializers.DecimalField(max_digits=14, decimal_places=2)
    total_ves = serializers.DecimalField(max_digits=14, decimal_places=2)
    cost_usd = serializers.DecimalField(max_digits=14, decimal_places=2)
    cost_ves = serializers.DecimalField(max_digits=14, decimal_places=2)
    profit_usd = serializers.DecimalField(max_digits=14, decimal_places=2)
    profit_ves = serializers.DecimalField(max_digits=14, decimal_places=2)
    payments = PaymentTotalSerializer(many=True)
    products = ProductSalesSerializer(many=True)
