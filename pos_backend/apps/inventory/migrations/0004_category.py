"""Las categorías dejan de ser una lista fija y pasan a ser filas que crea un MANAGER.

No se crea ninguna categoría por defecto: solo las que ya usaban los
productos existentes, con el nombre que tenían en el enum.
"""

import django.db.models.deletion
from django.db import migrations, models

LEGACY_CATEGORIES = {
    "LIQUIDS": "Líquidos",
    "POWDERS": "Polvos",
    "ACCESSORIES": "Accesorios",
}


def create_categories_and_link_products(apps, schema_editor):
    Category = apps.get_model("inventory", "Category")
    Product = apps.get_model("inventory", "Product")

    used = Product.objects.order_by().values_list("legacy_category", flat=True).distinct()
    for code in used:
        # Un valor que no esté en el enum original conserva su texto como nombre.
        category = Category.objects.create(name=LEGACY_CATEGORIES.get(code, code))
        Product.objects.filter(legacy_category=code).update(category=category)


def restore_legacy_values(apps, schema_editor):
    Product = apps.get_model("inventory", "Product")

    codes = {name: code for code, name in LEGACY_CATEGORIES.items()}
    for product in Product.objects.select_related("category"):
        # Las categorías creadas después no existían en el enum: se guarda su nombre recortado.
        product.legacy_category = codes.get(product.category.name, product.category.name[:20])
        product.save(update_fields=["legacy_category"])


class Migration(migrations.Migration):

    dependencies = [
        ("inventory", "0003_alter_branchinventory_branch_and_more"),
    ]

    operations = [
        migrations.CreateModel(
            name="Category",
            fields=[
                (
                    "id",
                    models.BigAutoField(
                        auto_created=True, primary_key=True, serialize=False, verbose_name="ID"
                    ),
                ),
                ("created_at", models.DateTimeField(auto_now_add=True)),
                ("updated_at", models.DateTimeField(auto_now=True)),
                ("name", models.CharField(max_length=100, unique=True)),
                ("active", models.BooleanField(default=True)),
            ],
            options={
                "verbose_name_plural": "categories",
                "ordering": ["name"],
            },
        ),
        migrations.RenameField(
            model_name="product", old_name="category", new_name="legacy_category"
        ),
        migrations.AlterField(
            model_name="product",
            name="legacy_category",
            field=models.CharField(max_length=20, default=""),
        ),
        migrations.AddField(
            model_name="product",
            name="category",
            field=models.ForeignKey(
                null=True,
                on_delete=django.db.models.deletion.PROTECT,
                related_name="products",
                to="inventory.category",
            ),
        ),
        migrations.RunPython(create_categories_and_link_products, restore_legacy_values),
        migrations.AlterField(
            model_name="product",
            name="category",
            field=models.ForeignKey(
                on_delete=django.db.models.deletion.PROTECT,
                related_name="products",
                to="inventory.category",
            ),
        ),
        migrations.RemoveField(model_name="product", name="legacy_category"),
    ]
