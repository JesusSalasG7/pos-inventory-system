from django.urls import path

from apps.statistics.api import views

urlpatterns = [
    path("statistics/summary/", views.SummaryView.as_view(), name="statistics-summary"),
    path(
        "statistics/credit-breakdown/",
        views.CreditBreakdownView.as_view(),
        name="statistics-credit-breakdown",
    ),
    path("statistics/groups/", views.GroupPerformanceView.as_view(), name="statistics-groups"),
    path(
        "statistics/products/ranking/",
        views.ProductRankingView.as_view(),
        name="statistics-product-ranking",
    ),
    path("statistics/matrix/", views.MatrixView.as_view(), name="statistics-matrix"),
    path(
        "statistics/inventory-health/",
        views.InventoryHealthView.as_view(),
        name="statistics-inventory-health",
    ),
]
