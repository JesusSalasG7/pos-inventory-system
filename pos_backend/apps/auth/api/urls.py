from django.urls import path
from drf_spectacular.utils import extend_schema, extend_schema_view
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView

from apps.auth.api.views import MeView, UserDetailView, UserListCreateView

# Login y refresh usan las vistas de SimpleJWT; aquí solo se etiquetan para la doc.
LoginView = extend_schema_view(post=extend_schema(operation_id="auth_login", tags=["auth"]))(
    TokenObtainPairView
)
RefreshView = extend_schema_view(post=extend_schema(operation_id="auth_refresh", tags=["auth"]))(
    TokenRefreshView
)

urlpatterns = [
    path("auth/login/", LoginView.as_view(), name="auth-login"),
    path("auth/refresh/", RefreshView.as_view(), name="auth-refresh"),
    path("auth/me/", MeView.as_view(), name="auth-me"),
    path("users/", UserListCreateView.as_view(), name="user-list"),
    path("users/<int:id>/", UserDetailView.as_view(), name="user-detail"),
]
