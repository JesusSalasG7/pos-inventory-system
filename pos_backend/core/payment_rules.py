"""Reglas de los métodos de pago, compartidas por las ventas y los abonos de crédito."""

from core.enums import Currency, PaymentMethod

# Moneda en la que se liquida cada método de pago.
METHOD_CURRENCY = {
    PaymentMethod.CASH_USD: Currency.USD,
    PaymentMethod.CASH_VES: Currency.VES,
    PaymentMethod.POS_CARD: Currency.VES,
    PaymentMethod.MOBILE_PAYMENT: Currency.VES,
    PaymentMethod.CREDIT: Currency.USD,
}
# Métodos electrónicos: exigen la referencia de aprobación del banco o terminal.
REFERENCE_REQUIRED = frozenset({PaymentMethod.POS_CARD, PaymentMethod.MOBILE_PAYMENT})
# Métodos con los que entra efectivo a la gaveta.
CASH_METHODS = frozenset({PaymentMethod.CASH_USD, PaymentMethod.CASH_VES})
