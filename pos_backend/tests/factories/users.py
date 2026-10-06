import factory

from apps.auth.models import User
from core.enums import Role

from .branches import VILLA_LIBERTAD, BranchCodeMixin

DEFAULT_PASSWORD = "Test-pass-123!"


class UserFactory(BranchCodeMixin, factory.django.DjangoModelFactory):
    _branch_fields = ("assigned_branch",)

    class Meta:
        model = User
        skip_postgeneration_save = True

    username = factory.Sequence(lambda n: f"user{n}")
    full_name = factory.Faker("name")
    role = Role.SUPERVISOR
    assigned_branch = VILLA_LIBERTAD

    @factory.post_generation
    def password(self, create: bool, extracted: str | None, **kwargs: object) -> None:
        self.set_password(extracted or DEFAULT_PASSWORD)
        if create:
            self.save()
