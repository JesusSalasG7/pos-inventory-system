import 'package:flutter/material.dart';

import 'package:pos_app/core/domain/enums.dart';
import 'package:pos_app/core/l10n/strings.dart';
import 'package:pos_app/core/theme/app_colors.dart';

/// Ícono y color de cada categoría. El backend no tiene imágenes de producto,
/// así que la categoría es la pista visual para reconocerlo rápido.
@immutable
class CategoryStyle {
  const CategoryStyle({required this.icon, required this.color, required this.softColor});

  final IconData icon;
  final Color color;
  final Color softColor;

  static CategoryStyle of(ProductCategory category) => switch (category) {
    ProductCategory.liquids => const CategoryStyle(
      icon: Icons.water_drop_rounded,
      color: AppColors.categoryLiquids,
      softColor: AppColors.categoryLiquidsSoft,
    ),
    ProductCategory.powders => const CategoryStyle(
      icon: Icons.grain_rounded,
      color: AppColors.categoryPowders,
      softColor: AppColors.categoryPowdersSoft,
    ),
    ProductCategory.accessories => const CategoryStyle(
      icon: Icons.cleaning_services_rounded,
      color: AppColors.categoryAccessories,
      softColor: AppColors.categoryAccessoriesSoft,
    ),
    ProductCategory.other => const CategoryStyle(
      icon: Icons.category_rounded,
      color: AppColors.textSecondary,
      softColor: AppColors.surfaceMuted,
    ),
  };

  static String labelOf(ProductCategory category) => Strings.category(category);
}
