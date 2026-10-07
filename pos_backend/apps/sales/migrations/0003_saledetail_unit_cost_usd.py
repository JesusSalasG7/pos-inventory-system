"""Cada línea de venta guarda el costo del producto al facturar.

Las ventas anteriores no lo tenían: se rellenan con el costo actual del
producto, que es la mejor aproximación disponible.
"""

from django.db import migrations, models
from django.db.models import OuterRef, Subquery


def copy_current_product_cost(apps, schema_editor):
    SaleDetail = apps.get_model("sales", "SaleDetail")
    Product = apps.get_model("inventory", "Product")

    current_cost = Product.objects.filter(pk=OuterRef("product_id")).values("cost_price_usd")[:1]
    SaleDetail.objects.update(unit_cost_usd=Subquery(current_cost))


class Migration(migrations.Migration):

    dependencies = [
        ("inventory", "0004_category"),
        ("sales", "0002_alter_sale_branch"),
    ]

    operations = [
        migrations.AddField(
            model_name="saledetail",
            name="unit_cost_usd",
            field=models.DecimalField(decimal_places=2, default=0, max_digits=14),
            preserve_default=False,
        ),
        migrations.RunPython(copy_current_product_cost, migrations.RunPython.noop),
    ]
