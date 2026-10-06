from django.urls import path

from apps.cash_sessions.api import views

urlpatterns = [
    path("cash-sessions/", views.CashSessionListCreateView.as_view(), name="cash-session-list"),
    path(
        "cash-sessions/current/",
        views.CurrentCashSessionView.as_view(),
        name="cash-session-current",
    ),
    path(
        "cash-sessions/<int:id>/expenses/",
        views.CashExpenseListCreateView.as_view(),
        name="cash-session-expenses",
    ),
    path(
        "cash-sessions/<int:id>/summary/",
        views.CashSessionSummaryView.as_view(),
        name="cash-session-summary",
    ),
    path(
        "cash-sessions/<int:id>/close/",
        views.CashSessionCloseView.as_view(),
        name="cash-session-close",
    ),
]
