"""Paginación estándar de la API."""

from rest_framework.pagination import PageNumberPagination


class StandardPagination(PageNumberPagination):
    """Paginación por número de página con tamaño ajustable por el cliente."""

    page_size = 25
    page_size_query_param = "page_size"
    max_page_size = 200
