import pytest
from rest_framework.test import APIClient

from apps.auth.models import User
from tests.factories import DEFAULT_PASSWORD

pytestmark = pytest.mark.django_db

LOGIN_URL = "/api/v1/auth/login/"


def test_login_returns_token_pair(api_client: APIClient, supervisor: User) -> None:
    response = api_client.post(
        LOGIN_URL, {"username": supervisor.username, "password": DEFAULT_PASSWORD}, format="json"
    )

    assert response.status_code == 200
    assert set(response.data) == {"access", "refresh"}


def test_login_with_wrong_password_is_rejected(api_client: APIClient, supervisor: User) -> None:
    response = api_client.post(
        LOGIN_URL, {"username": supervisor.username, "password": "wrong"}, format="json"
    )

    assert response.status_code == 401
    assert set(response.data) == {"code", "detail", "meta"}
    assert "access" not in response.data


def test_login_with_inactive_user_is_rejected(api_client: APIClient, supervisor: User) -> None:
    supervisor.is_active = False
    supervisor.save(update_fields=["is_active"])

    response = api_client.post(
        LOGIN_URL, {"username": supervisor.username, "password": DEFAULT_PASSWORD}, format="json"
    )

    assert response.status_code == 401


def test_refresh_returns_new_access_token(api_client: APIClient, supervisor: User) -> None:
    tokens = api_client.post(
        LOGIN_URL, {"username": supervisor.username, "password": DEFAULT_PASSWORD}, format="json"
    ).data

    response = api_client.post(
        "/api/v1/auth/refresh/", {"refresh": tokens["refresh"]}, format="json"
    )

    assert response.status_code == 200
    assert "access" in response.data


def test_me_requires_and_accepts_the_access_token(api_client: APIClient, supervisor: User) -> None:
    assert api_client.get("/api/v1/auth/me/").status_code == 401

    access = api_client.post(
        LOGIN_URL, {"username": supervisor.username, "password": DEFAULT_PASSWORD}, format="json"
    ).data["access"]
    api_client.credentials(HTTP_AUTHORIZATION=f"Bearer {access}")
    response = api_client.get("/api/v1/auth/me/")

    assert response.status_code == 200
    assert response.data["username"] == supervisor.username
