from django.urls import path

from apps.exchange_rate.api import views

urlpatterns = [
    path("exchange-rates/", views.ExchangeRateListCreateView.as_view(), name="exchange-rate-list"),
    path(
        "exchange-rates/current/",
        views.CurrentExchangeRateView.as_view(),
        name="exchange-rate-current",
    ),
    path("exchange-rates/bcv/", views.BcvRateView.as_view(), name="exchange-rate-bcv"),
]
