from django.utils import timezone
from drf_spectacular.utils import extend_schema_field
from rest_framework import serializers

from apps.credits.models import Credit, CreditPayment, CreditPaymentAllocation, Customer
from apps.credits.services.credit_service import CreditStatus
from apps.credits.services.customer_service import MAX_CREDIT_DAYS
from core.enums import Currency, PaymentMethod
from core.money import quantize_rate, usd_to_ves

MONEY_OR_NULL = serializers.DecimalField(max_digits=14, decimal_places=2, allow_null=True)
RATE_OR_NULL = serializers.DecimalField(max_digits=14, decimal_places=4, allow_null=True)


class CustomerSerializer(serializers.ModelSerializer):
    """Cliente con lo que debe en la sucursal consultada.

    `balance_ves` es el saldo en bolívares a la tasa del BCV del día
    (`payment_rate`): lo que pagaría hoy si abonara todo en bolívares.
    """

    balance_usd = serializers.DecimalField(max_digits=14, decimal_places=2, read_only=True)
    overdue_usd = serializers.DecimalField(max_digits=14, decimal_places=2, read_only=True)
    open_credits = serializers.IntegerField(read_only=True)
    next_due_date = serializers.DateField(read_only=True, allow_null=True)
    balance_ves = serializers.SerializerMethodField()
    payment_rate = serializers.SerializerMethodField()

    class Meta:
        model = Customer
        fields = [
            "id",
            "name",
            "tax_id",
            "phone",
            "credit_days",
            "active",
            "balance_usd",
            "overdue_usd",
            "open_credits",
            "next_due_date",
            "balance_ves",
            "payment_rate",
            "created_at",
        ]
        read_only_fields = fields

    # Como string, igual que los DecimalField: el dinero nunca viaja como número.
    @extend_schema_field(MONEY_OR_NULL)
    def get_balance_ves(self, customer: Customer) -> str | None:
        rate = self.context.get("payment_rate")
        return str(usd_to_ves(customer.balance_usd, rate)) if rate else None

    @extend_schema_field(RATE_OR_NULL)
    def get_payment_rate(self, customer: Customer) -> str | None:
        rate = self.context.get("payment_rate")
        return str(quantize_rate(rate)) if rate else None


class CustomerCreateSerializer(serializers.Serializer):
    name = serializers.CharField(max_length=150)
    tax_id = serializers.CharField(max_length=20, required=False, allow_blank=True)
    phone = serializers.CharField(max_length=30, required=False, allow_blank=True)
    credit_days = serializers.IntegerField(
        min_value=0, max_value=MAX_CREDIT_DAYS, required=False, help_text="Plazo propuesto."
    )


class CustomerUpdateSerializer(CustomerCreateSerializer):
    name = serializers.CharField(max_length=150, required=False)
    active = serializers.BooleanField(required=False)


class CustomerQuerySerializer(serializers.Serializer):
    branch = serializers.CharField(max_length=20, required=False)
    search = serializers.CharField(max_length=100, required=False, allow_blank=True)
    active = serializers.BooleanField(required=False, help_text="Solo clientes activos.")
    with_debt = serializers.BooleanField(required=False, help_text="Solo clientes que deben.")


class CreditSerializer(serializers.ModelSerializer):
    customer_name = serializers.CharField(source="customer.name", read_only=True)
    customer_phone = serializers.CharField(source="customer.phone", read_only=True)
    branch = serializers.CharField(source="branch_id", read_only=True)
    is_overdue = serializers.SerializerMethodField()

    class Meta:
        model = Credit
        fields = [
            "id",
            "sale",
            "customer",
            "customer_name",
            "customer_phone",
            "branch",
            "amount_usd",
            "balance_usd",
            "due_date",
            "paid_at",
            "is_overdue",
            "created_at",
        ]
        read_only_fields = fields

    def get_is_overdue(self, credit: Credit) -> bool:
        return credit.balance_usd > 0 and credit.due_date < timezone.localdate()


class CreditQuerySerializer(serializers.Serializer):
    branch = serializers.CharField(max_length=20, required=False)
    customer = serializers.IntegerField(min_value=1, required=False)
    status = serializers.ChoiceField(
        choices=CreditStatus.choices, required=False, default=CreditStatus.PENDING
    )


class CreditPaymentAllocationSerializer(serializers.ModelSerializer):
    class Meta:
        model = CreditPaymentAllocation
        fields = ["credit", "amount_usd"]
        read_only_fields = fields


class CreditPaymentSerializer(serializers.ModelSerializer):
    branch = serializers.CharField(source="branch_id", read_only=True)
    allocations = CreditPaymentAllocationSerializer(many=True, read_only=True)

    class Meta:
        model = CreditPayment
        fields = [
            "id",
            "customer",
            "cash_session",
            "user",
            "branch",
            "method",
            "currency",
            "amount",
            "approval_reference",
            "usd_to_ves_rate",
            "amount_usd",
            "allocations",
            "created_at",
        ]
        read_only_fields = fields


class CreditPaymentCreateSerializer(serializers.Serializer):
    method = serializers.ChoiceField(choices=PaymentMethod.choices)
    currency = serializers.ChoiceField(choices=Currency.choices)
    amount = serializers.DecimalField(max_digits=14, decimal_places=2, min_value=0)
    approval_reference = serializers.CharField(max_length=50, required=False, allow_blank=True)
