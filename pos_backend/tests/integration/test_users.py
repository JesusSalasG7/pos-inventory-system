import pytest
from rest_framework.test import APIClient

from apps.auth.models import User
from apps.auth.services import user_service
from core.enums import Role
from core.exceptions import DomainError
from tests.factories import LAS_AMERICAS, CashSessionFactory, UserFactory

pytestmark = pytest.mark.django_db

USERS_URL = "/api/v1/users/"
LOGIN_URL = "/api/v1/auth/login/"
PASSWORD = "Caja-segura-2026"
NEW_USER = {
    "username": "cperez",
    "password": PASSWORD,
    "full_name": "Carlos Perez",
    "role": Role.SUPERVISOR,
    "assigned_branch": LAS_AMERICAS,
}


def test_create_user_hashes_the_password() -> None:
    user = user_service.create_user(
        **{**NEW_USER, "username": "  cperez ", "full_name": " Carlos "}
    )

    user.refresh_from_db()
    assert (user.username, user.full_name) == ("cperez", "Carlos")
    assert user.role == Role.SUPERVISOR
    assert user.assigned_branch_id == LAS_AMERICAS
    assert user.is_active and not user.is_staff
    assert user.password != PASSWORD
    assert user.check_password(PASSWORD)


def test_username_must_be_unique_ignoring_case() -> None:
    user_service.create_user(**NEW_USER)

    with pytest.raises(DomainError) as exc_info:
        user_service.create_user(**{**NEW_USER, "username": "CPerez"})

    assert exc_info.value.code == "username_taken"
    assert exc_info.value.status_code == 409
    assert User.objects.count() == 1


def test_username_race_is_translated(monkeypatch: pytest.MonkeyPatch) -> None:
    user_service.create_user(**NEW_USER)
    monkeypatch.setattr(
        "apps.auth.repositories.user_repository.exists_by_username", lambda username: False
    )

    with pytest.raises(DomainError) as exc_info:
        user_service.create_user(**NEW_USER)

    assert exc_info.value.code == "username_taken"


@pytest.mark.parametrize(
    ("override", "code"),
    [
        ({"username": "  "}, "invalid_username"),
        ({"full_name": " "}, "invalid_full_name"),
        ({"password": "12345678"}, "invalid_password"),  # común y solo numérica
        ({"password": "cperez123"}, "invalid_password"),  # parecida al username
        ({"assigned_branch": None}, "invalid_branch_assignment"),
    ],
)
def test_create_user_validates_input(override: dict, code: str) -> None:
    with pytest.raises(DomainError) as exc_info:
        user_service.create_user(**{**NEW_USER, **override})

    assert exc_info.value.code == code
    assert exc_info.value.status_code == 422
    assert not User.objects.exists()


def test_manager_can_be_assigned_to_all_branches() -> None:
    user = user_service.create_user(**{**NEW_USER, "role": Role.MANAGER, "assigned_branch": None})

    assert user.assigned_branch_id is None


def test_get_and_list_users(manager: User) -> None:
    inactive = UserFactory(is_active=False)

    assert user_service.get_user(manager.pk) == manager
    assert set(user_service.list_users()) == {manager, inactive}
    assert list(user_service.list_users(only_active=True)) == [manager]
    with pytest.raises(DomainError) as exc_info:
        user_service.get_user(999_999)
    assert exc_info.value.code == "user_not_found"


def test_update_user(manager: User, supervisor: User) -> None:
    updated = user_service.update_user(
        supervisor.pk,
        manager,
        full_name=" Nuevo Nombre ",
        assigned_branch=LAS_AMERICAS,
        password=PASSWORD,
    )

    updated.refresh_from_db()
    assert updated.full_name == "Nuevo Nombre"
    assert updated.assigned_branch_id == LAS_AMERICAS
    assert updated.check_password(PASSWORD)
    with pytest.raises(ValueError):
        user_service.update_user(supervisor.pk, manager, username="otro")
    with pytest.raises(DomainError) as exc_info:
        user_service.update_user(supervisor.pk, manager, password="123")
    assert exc_info.value.code == "invalid_password"


def test_update_keeps_role_and_branch_coherent(manager: User, supervisor: User) -> None:
    with pytest.raises(DomainError) as exc_info:
        user_service.update_user(supervisor.pk, manager, assigned_branch=None)
    assert exc_info.value.code == "invalid_branch_assignment"

    promoted = user_service.update_user(
        supervisor.pk, manager, role=Role.MANAGER, assigned_branch=None
    )
    assert promoted.role == Role.MANAGER

    # Degradarlo sin cambiarle la sucursal lo dejaría como SUPERVISOR con ALL.
    with pytest.raises(DomainError) as exc_info:
        user_service.update_user(supervisor.pk, manager, role=Role.SUPERVISOR)
    assert exc_info.value.code == "invalid_branch_assignment"


def test_user_with_open_session_cannot_be_moved_or_deactivated(
    manager: User, supervisor: User
) -> None:
    CashSessionFactory(user=supervisor)

    for change in ({"is_active": False}, {"assigned_branch": LAS_AMERICAS}):
        with pytest.raises(DomainError) as exc_info:
            user_service.update_user(supervisor.pk, manager, **change)
        assert exc_info.value.code == "user_has_open_session"
        assert exc_info.value.status_code == 409

    # Lo que no afecta a la caja sí se permite.
    assert user_service.update_user(supervisor.pk, manager, full_name="Otro").full_name == "Otro"


def test_manager_cannot_lock_themselves_out(manager: User) -> None:
    for change in ({"is_active": False}, {"role": Role.SUPERVISOR}):
        with pytest.raises(DomainError) as exc_info:
            user_service.update_user(manager.pk, manager, **change)
        assert exc_info.value.code == "cannot_modify_own_access"

    assert user_service.update_user(manager.pk, manager, full_name="Yo").full_name == "Yo"


def test_user_lifecycle_through_api(api_client: APIClient, manager: User) -> None:
    api_client.force_authenticate(manager)

    created = api_client.post(USERS_URL, NEW_USER, format="json")
    assert created.status_code == 201
    assert "password" not in created.data
    detail_url = f"{USERS_URL}{created.data['id']}/"

    duplicate = api_client.post(USERS_URL, NEW_USER, format="json")
    assert duplicate.status_code == 409
    assert duplicate.data["code"] == "username_taken"
    assert api_client.get(detail_url).data["username"] == "cperez"
    assert api_client.get(USERS_URL).data["count"] == 2

    anonymous = APIClient()
    credentials = {"username": "cperez", "password": PASSWORD}
    assert anonymous.post(LOGIN_URL, credentials, format="json").status_code == 200

    deactivated = api_client.patch(detail_url, {"is_active": False}, format="json")
    assert deactivated.status_code == 200
    assert deactivated.data["is_active"] is False
    assert anonymous.post(LOGIN_URL, credentials, format="json").status_code == 401
    assert api_client.get(USERS_URL, {"active": "true"}).data["count"] == 1
    assert api_client.get(f"{USERS_URL}999999/").status_code == 404


def test_only_managers_manage_users(api_client: APIClient, supervisor: User) -> None:
    api_client.force_authenticate(supervisor)

    assert api_client.get(USERS_URL).status_code == 403
    assert api_client.post(USERS_URL, NEW_USER, format="json").status_code == 403
    assert api_client.get(f"{USERS_URL}{supervisor.pk}/").status_code == 403
    assert api_client.patch(f"{USERS_URL}{supervisor.pk}/", {}, format="json").status_code == 403
