"""Excepciones de dominio.

Los services lanzan estas excepciones y `core.exception_handler` las traduce
a la respuesta HTTP `{"code", "detail", "meta"}`.
"""

from typing import Any


class DomainError(Exception):
    """Error de regla de negocio con código estable para el cliente."""

    code: str = "domain_error"
    detail: str = "Error de dominio."
    status_code: int = 400

    def __init__(
        self,
        detail: str | None = None,
        *,
        code: str | None = None,
        status_code: int | None = None,
        meta: dict[str, Any] | None = None,
    ) -> None:
        self.code = code or self.code
        self.detail = detail or self.detail
        self.status_code = status_code or self.status_code
        self.meta = meta or {}
        super().__init__(self.detail)


class NoOpenSessionError(DomainError):
    code = "no_open_session"
    detail = "El usuario no tiene una caja abierta en la sucursal."
    status_code = 409


class InsufficientStockError(DomainError):
    code = "insufficient_stock"
    detail = "No hay stock suficiente para completar la operación."
    status_code = 422


class PaymentMismatchError(DomainError):
    code = "payment_mismatch"
    detail = "La suma de los pagos no cuadra con el total de la venta."
    status_code = 422


class BranchAccessDeniedError(DomainError):
    code = "branch_access_denied"
    detail = "El usuario no tiene acceso a la sucursal solicitada."
    status_code = 403


class InactiveProductError(DomainError):
    code = "inactive_product"
    detail = "El producto no existe o está inactivo."
    status_code = 422


class NotFoundError(DomainError):
    code = "not_found"
    detail = "El recurso solicitado no existe."
    status_code = 404
