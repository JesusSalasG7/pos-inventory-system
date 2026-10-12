"""DTOs inmutables de entrada para los services de créditos."""

from dataclasses import dataclass
from decimal import Decimal

from core.enums import Currency, PaymentMethod


@dataclass(frozen=True)
class CreditPaymentInput:
    """Abono de un cliente. Los bolívares se pasan a USD con la tasa del BCV del día."""

    customer_id: int
    method: PaymentMethod
    currency: Currency
    amount: Decimal
    approval_reference: str = ""
