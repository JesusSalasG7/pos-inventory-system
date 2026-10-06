from django.urls import path

from apps.sales.api import views

urlpatterns = [
    path("sales/", views.SaleListCreateView.as_view(), name="sale-list"),
    path(
        "sales/reports/summary/",
        views.SalesSummaryReportView.as_view(),
        name="sale-report-summary",
    ),
    path("sales/<int:id>/", views.SaleDetailView.as_view(), name="sale-detail"),
]
