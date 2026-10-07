from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ("inventory", "0004_category"),
    ]

    operations = [
        migrations.AddField(
            model_name="category",
            name="icon",
            field=models.CharField(blank=True, default="", max_length=16),
        ),
    ]
