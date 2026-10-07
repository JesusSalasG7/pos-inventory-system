"""Cada venta guarda la tasa del BCV al facturar, con la que se valora el costo.

Las ventas anteriores se rellenan con la última tasa de origen BCV registrada
antes de la venta; si no había ninguna, con la tasa a la que se facturó.
"""

from django.db import migrations, models
from django.db.models import F, OuterRef, Subquery
from django.db.models.functions import Coalesce


def fill_bcv_rate(apps, schema_editor):
    Sale = apps.get_model("sales", "Sale")
    ExchangeRate = apps.get_model("exchange_rate", "ExchangeRate")

    bcv_rate = (
        ExchangeRate.objects.filter(source="BCV", created_at__lte=OuterRef("created_at"))
        .order_by("-created_at", "-id")
        .values("usd_to_ves_rate")[:1]
    )
    Sale.objects.update(
        bcv_rate_at_invoice=Coalesce(Subquery(bcv_rate), F("exchange_rate_at_invoice"))
    )


class Migration(migrations.Migration):

    dependencies = [
        ("exchange_rate", "0003_pricingsettings"),
        ("sales", "0004_saledetail_subtotal_ves"),
    ]

    operations = [
        migrations.AddField(
            model_name="sale",
            name="bcv_rate_at_invoice",
            field=models.DecimalField(decimal_places=4, default=0, max_digits=14),
            preserve_default=False,
        ),
        migrations.RunPython(fill_bcv_rate, migrations.RunPython.noop),
    ]
