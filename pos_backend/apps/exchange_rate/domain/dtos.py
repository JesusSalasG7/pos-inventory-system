"""Objetos de valor de la tasa de cambio."""

from dataclasses import dataclass
from datetime import datetime
from decimal import Decimal


@dataclass(frozen=True)
class BcvRate:
    """Tasa oficial del BCV tal como la publica la fuente externa."""

    # Cantidad de VES equivalente a 1 USD, redondeada a 4 decimales.
    rate: Decimal
    updated_at: datetime
