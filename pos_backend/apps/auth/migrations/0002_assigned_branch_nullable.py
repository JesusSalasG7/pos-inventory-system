"""Prepara `assigned_branch` para ser una FK: el valor "ALL" pasa a ser NULL."""

from django.db import migrations, models


def all_to_null(apps, schema_editor):
    User = apps.get_model("accounts", "User")
    User.objects.filter(assigned_branch="ALL").update(assigned_branch=None)


def null_to_all(apps, schema_editor):
    User = apps.get_model("accounts", "User")
    User.objects.filter(assigned_branch__isnull=True).update(assigned_branch="ALL")


class Migration(migrations.Migration):
    dependencies = [
        ("accounts", "0001_initial"),
    ]

    operations = [
        migrations.AlterField(
            model_name="user",
            name="assigned_branch",
            field=models.CharField(max_length=20, null=True, blank=True),
        ),
        migrations.RunPython(all_to_null, null_to_all),
    ]
