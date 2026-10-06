import 'package:flutter/material.dart';

import 'package:pos_app/core/constants/category_style.dart';
import 'package:pos_app/core/domain/enums.dart';
import 'package:pos_app/core/l10n/strings.dart';
import 'package:pos_app/core/theme/app_colors.dart';
import 'package:pos_app/core/theme/app_spacing.dart';
import 'package:pos_app/core/theme/app_typography.dart';

/// Fila horizontal de chips para filtrar por categoría. `null` es "Todos".
class CategoryFilterChips extends StatelessWidget {
  const CategoryFilterChips({
    required this.selected,
    required this.onSelected,
    this.categories = ProductCategory.known,
    this.padding = const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
    super.key,
  });

  final ProductCategory? selected;
  final ValueChanged<ProductCategory?> onSelected;
  final List<ProductCategory> categories;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final options = <ProductCategory?>[null, ...categories];
    return SizedBox(
      height: AppSpacing.minTouchTarget,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: padding,
        itemCount: options.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final category = options[index];
          final isSelected = category == selected;
          return ChoiceChip(
            selected: isSelected,
            onSelected: (_) => onSelected(category),
            avatar: category == null
                ? null
                : Icon(
                    CategoryStyle.of(category).icon,
                    size: 18,
                    color: isSelected ? AppColors.onPrimary : CategoryStyle.of(category).color,
                  ),
            label: Text(category == null ? Strings.all : CategoryStyle.labelOf(category)),
            labelStyle: AppTypography.label.copyWith(
              fontSize: 14,
              color: isSelected ? AppColors.onPrimary : AppColors.textPrimary,
            ),
          );
        },
      ),
    );
  }
}
