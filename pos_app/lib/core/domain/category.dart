import 'package:flutter/foundation.dart';

/// Categoría del catálogo. Las crea y administra un MANAGER; no se borran,
/// se desactivan.
@immutable
class ProductCategory {
  const ProductCategory({required this.id, required this.name, this.icon = '', this.active = true});

  final int id;
  final String name;

  /// Sticker (emoji) que eligió el gerente; vacío si la app asigna el ícono.
  final String icon;

  bool get hasSticker => icon.isNotEmpty;

  /// Una categoría inactiva conserva sus productos pero no admite nuevos.
  final bool active;

  @override
  bool operator ==(Object other) =>
      other is ProductCategory &&
      other.id == id &&
      other.name == name &&
      other.icon == icon &&
      other.active == active;

  @override
  int get hashCode => Object.hash(id, name, icon, active);
}

/// Subcategoría: el segundo nivel del catálogo, dentro de una categoría. Las
/// crea un MANAGER; no se borran, se desactivan.
@immutable
class ProductSubcategory {
  const ProductSubcategory({
    required this.id,
    required this.categoryId,
    required this.name,
    this.active = true,
  });

  final int id;
  final int categoryId;
  final String name;

  /// Una subcategoría inactiva conserva sus productos pero no admite nuevos.
  final bool active;

  @override
  bool operator ==(Object other) =>
      other is ProductSubcategory &&
      other.id == id &&
      other.categoryId == categoryId &&
      other.name == name &&
      other.active == active;

  @override
  int get hashCode => Object.hash(id, categoryId, name, active);
}
