"""Manejador global de excepciones de DRF.

Unifica todas las respuestas de error en `{"code", "detail", "meta"}`.
"""

from typing import Any

from rest_framework import status
from rest_framework.exceptions import APIException, ValidationError
from rest_framework.response import Response
from rest_framework.views import exception_handler

from core.exceptions import DomainError


def domain_exception_handler(exc: Exception, context: dict[str, Any]) -> Response | None:
    """Traduce errores de dominio y de DRF al sobre de error común."""
    if isinstance(exc, DomainError):
        return _error_response(exc.code, exc.detail, exc.meta, exc.status_code)

    response = exception_handler(exc, context)
    if response is None:
        # Error no controlado: Django responde 500 y lo registra.
        return None

    if isinstance(exc, ValidationError):
        response.data = _envelope(
            "validation_error", "Los datos enviados no son válidos.", {"errors": response.data}
        )
        return response

    data = response.data if isinstance(response.data, dict) else {}
    code = data.get("code") or getattr(exc, "default_code", None) or _fallback_code(response)
    detail = data.get("detail") or getattr(exc, "detail", None) or "Error."
    meta = {key: value for key, value in data.items() if key not in ("code", "detail")}
    response.data = _envelope(str(code), str(detail), meta)
    return response


def _fallback_code(response: Response) -> str:
    return (
        "not_found"
        if response.status_code == status.HTTP_404_NOT_FOUND
        else APIException.default_code
    )


def _envelope(code: str, detail: str, meta: dict[str, Any]) -> dict[str, Any]:
    return {"code": code, "detail": detail, "meta": meta}


def _error_response(code: str, detail: str, meta: dict[str, Any], status_code: int) -> Response:
    return Response(_envelope(code, detail, meta), status=status_code)
