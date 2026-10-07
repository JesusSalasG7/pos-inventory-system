from django.urls import path

from apps.inventory.api import views

urlpatterns = [
    path("categories/", views.CategoryListCreateView.as_view(), name="category-list"),
    path("categories/<int:id>/", views.CategoryDetailView.as_view(), name="category-detail"),
    path("products/", views.ProductListCreateView.as_view(), name="product-list"),
    path("products/<int:id>/", views.ProductDetailView.as_view(), name="product-detail"),
    path(
        "products/<int:id>/toggle-active/",
        views.ProductToggleActiveView.as_view(),
        name="product-toggle-active",
    ),
    path("inventory/", views.BranchInventoryListView.as_view(), name="inventory-list"),
    path("inventory/low-stock/", views.LowStockListView.as_view(), name="inventory-low-stock"),
    path(
        "inventory/movements/",
        views.InventoryMovementListCreateView.as_view(),
        name="inventory-movement-list",
    ),
    path(
        "inventory/<int:product_id>/minimum-stock/",
        views.MinimumStockView.as_view(),
        name="inventory-minimum-stock",
    ),
]
