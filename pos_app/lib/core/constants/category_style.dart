import 'package:flutter/material.dart';

import 'package:pos_app/core/domain/category.dart';
import 'package:pos_app/core/theme/app_colors.dart';

/// Ícono y color de una categoría. El backend no tiene imágenes de producto,
/// así que la categoría es la pista visual para reconocerlo rápido.
///
/// Las categorías las crea el gerente y no guardan ícono ni color: se les
/// asigna uno de esta paleta según su `id`, de modo que cada categoría
/// conserva siempre el mismo.
@immutable
class CategoryStyle {
  const CategoryStyle({required this.icon, required this.color, required this.softColor});

  final IconData icon;
  final Color color;
  final Color softColor;

  static const List<CategoryStyle> _palette = [
    CategoryStyle(
      icon: Icons.water_drop_rounded,
      color: AppColors.categoryLiquids,
      softColor: AppColors.categoryLiquidsSoft,
    ),
    CategoryStyle(
      icon: Icons.grain_rounded,
      color: AppColors.categoryPowders,
      softColor: AppColors.categoryPowdersSoft,
    ),
    CategoryStyle(
      icon: Icons.cleaning_services_rounded,
      color: AppColors.categoryAccessories,
      softColor: AppColors.categoryAccessoriesSoft,
    ),
    CategoryStyle(
      icon: Icons.spa_rounded,
      color: AppColors.primaryDark,
      softColor: AppColors.primarySoft,
    ),
    CategoryStyle(
      icon: Icons.local_offer_rounded,
      color: AppColors.onAccent,
      softColor: AppColors.accentSoft,
    ),
    CategoryStyle(
      icon: Icons.category_rounded,
      color: AppColors.textSecondary,
      softColor: AppColors.surfaceMuted,
    ),
  ];

  static CategoryStyle of(ProductCategory category) =>
      _palette[(category.id - 1) % _palette.length];
}
