import factory

from apps.credits.models import Customer


class CustomerFactory(factory.django.DjangoModelFactory):
    class Meta:
        model = Customer

    name = factory.Sequence(lambda n: f"Cliente {n}")
    tax_id = factory.Sequence(lambda n: f"V-{1000 + n}")
    credit_days = 7
