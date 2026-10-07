"""Cada línea de venta guarda lo facturado en bolívares.

Las ventas anteriores se rellenan con su subtotal en USD convertido con la
tasa congelada de la venta, que es como se calculaban.
"""

from decimal import ROUND_HALF_UP, Decimal

from django.db import migrations, models


def fill_subtotal_ves(apps, schema_editor):
    SaleDetail = apps.get_model("sales", "SaleDetail")

    details = SaleDetail.objects.select_related("sale").iterator()
    for detail in details:
        detail.subtotal_ves = (detail.subtotal_usd * detail.sale.exchange_rate_at_invoice).quantize(
            Decimal("0.01"), rounding=ROUND_HALF_UP
        )
        detail.save(update_fields=["subtotal_ves"])


class Migration(migrations.Migration):

    dependencies = [
        ("sales", "0003_saledetail_unit_cost_usd"),
    ]

    operations = [
        migrations.AddField(
            model_name="saledetail",
            name="subtotal_ves",
            field=models.DecimalField(decimal_places=2, default=0, max_digits=14),
            preserve_default=False,
        ),
        migrations.RunPython(fill_subtotal_ves, migrations.RunPython.noop),
    ]
