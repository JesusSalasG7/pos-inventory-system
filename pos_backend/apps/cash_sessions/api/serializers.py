from rest_framework import serializers

from apps.cash_sessions.models import CashExpense, CashSession


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
