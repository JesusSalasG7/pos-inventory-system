from django.contrib import admin
from django.http import HttpRequest

from apps.branches.models import Branch
from apps.inventory.services import stock_service


@admin.register(Branch)
class BranchAdmin(admin.ModelAdmin):
    list_display = ("code", "name", "active")
    list_filter = ("active",)
    search_fields = ("code", "name")

    def get_readonly_fields(self, request: HttpRequest, obj: Branch | None = None) -> tuple:
        # El código es el identificador que usan las demás tablas: no se edita.
        return ("code",) if obj else ()

    def has_delete_permission(self, request: HttpRequest, obj: object = None) -> bool:
        return False

    def save_model(self, request: HttpRequest, obj: Branch, form: object, change: bool) -> None:
        super().save_model(request, obj, form, change)
        if obj.active:
            stock_service.initialize_branch(obj.code)
