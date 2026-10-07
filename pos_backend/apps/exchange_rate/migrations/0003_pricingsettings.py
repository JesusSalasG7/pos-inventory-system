from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ("exchange_rate", "0002_rate_source_and_effective_date"),
    ]

    operations = [
        migrations.CreateModel(
            name="PricingSettings",
            fields=[
                (
                    "id",
                    models.BigAutoField(
                        auto_created=True, primary_key=True, serialize=False, verbose_name="ID"
                    ),
                ),
                ("created_at", models.DateTimeField(auto_now_add=True)),
                ("updated_at", models.DateTimeField(auto_now=True)),
                (
                    "rate_mode",
                    models.CharField(
                        choices=[("BCV", "BCV automática"), ("MANUAL", "Tasa propia")],
                        default="BCV",
                        max_length=10,
                    ),
                ),
                ("round_ves_up", models.BooleanField(default=False)),
            ],
            options={
                "verbose_name_plural": "pricing settings",
            },
        ),
    ]
