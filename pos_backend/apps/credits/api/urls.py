from django.urls import path

from apps.credits.api import views

urlpatterns = [
    path("customers/", views.CustomerListCreateView.as_view(), name="customer-list"),
    path("customers/<int:id>/", views.CustomerDetailView.as_view(), name="customer-detail"),
    path(
        "customers/<int:id>/payments/",
        views.CustomerPaymentListCreateView.as_view(),
        name="customer-payments",
    ),
    path("credits/", views.CreditListView.as_view(), name="credit-list"),
]
