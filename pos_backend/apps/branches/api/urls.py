from django.urls import path

from apps.branches.api import views

urlpatterns = [
    path("branches/", views.BranchListCreateView.as_view(), name="branch-list"),
    path("branches/<str:code>/", views.BranchDetailView.as_view(), name="branch-detail"),
]
