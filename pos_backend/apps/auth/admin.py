from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as DjangoUserAdmin

from apps.auth.models import User


@admin.register(User)
class UserAdmin(DjangoUserAdmin):
    ordering = ("username",)
    list_display = ("username", "full_name", "role", "assigned_branch", "is_active", "is_staff")
    list_filter = ("role", "assigned_branch", "is_active", "is_staff")
    search_fields = ("username", "full_name")
    fieldsets = (
        (None, {"fields": ("username", "password")}),
        ("Datos", {"fields": ("full_name", "role", "assigned_branch")}),
        (
            "Permisos",
            {"fields": ("is_active", "is_staff", "is_superuser", "groups", "user_permissions")},
        ),
    )
    add_fieldsets = (
        (
            None,
            {
                "classes": ("wide",),
                "fields": (
                    "username",
                    "full_name",
                    "role",
                    "assigned_branch",
                    "password1",
                    "password2",
                ),
            },
        ),
    )
