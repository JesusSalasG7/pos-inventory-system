"""Registra como sucursales los códigos que ya usan los datos existentes.

Antes las sucursales eran un enum fijo guardado como texto. Para poder
convertir esas columnas en FK, cada código en uso debe existir en la tabla.
En una instalación nueva no hay datos y no se crea ninguna sucursal.
"""

from django.db import migrations

# Nombres de las sucursales del enum original.
KNOWN_NAMES = {
    "VILLA_LIBERTAD": "Villa Libertad",
    "LAS_AMERICAS": "Las Américas",
}

SOURCES = [
    ("accounts", "User", "assigned_branch"),
    ("inventory", "BranchInventory", "branch"),
    ("inventory", "InventoryMovement", "branch"),
    ("cash_sessions", "CashSession", "branch"),
    ("sales", "Sale", "branch"),
]


def create_branches(apps, schema_editor):
    Branch = apps.get_model("branches", "Branch")
    codes: set[str] = set()
    for app_label, model_name, field in SOURCES:
        model = apps.get_model(app_label, model_name)
        codes.update(
            model.objects.exclude(**{f"{field}__isnull": True})
            .values_list(field, flat=True)
            .distinct()
        )
    for code in sorted(codes):
        Branch.objects.get_or_create(
            code=code,
            defaults={"name": KNOWN_NAMES.get(code, code.replace("_", " ").title())},
        )


class Migration(migrations.Migration):
    dependencies = [
        ("branches", "0001_initial"),
        ("accounts", "0002_assigned_branch_nullable"),
        ("inventory", "0002_initial"),
        ("cash_sessions", "0001_initial"),
        ("sales", "0001_initial"),
    ]

    operations = [
        migrations.RunPython(create_branches, migrations.RunPython.noop),
    ]
