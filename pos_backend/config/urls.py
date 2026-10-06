"""Rutas raíz: admin, API v1 y documentación OpenAPI."""

from django.contrib import admin
from django.urls import include, path
from drf_spectacular.views import SpectacularAPIView, SpectacularSwaggerView

api_v1_patterns = [
    path("", include("apps.auth.api.urls")),
    path("", include("apps.branches.api.urls")),
    path("", include("apps.inventory.api.urls")),
    path("", include("apps.exchange_rate.api.urls")),
    path("", include("apps.cash_sessions.api.urls")),
    path("", include("apps.sales.api.urls")),
]

urlpatterns = [
    path("admin/", admin.site.urls),
    path("api/v1/", include(api_v1_patterns)),
    path("api/schema/", SpectacularAPIView.as_view(), name="schema"),
    path("api/docs/", SpectacularSwaggerView.as_view(url_name="schema"), name="docs"),
]
