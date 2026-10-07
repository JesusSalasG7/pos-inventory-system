import 'package:flutter/material.dart';

import 'package:pos_app/core/domain/category.dart';
import 'package:pos_app/core/l10n/strings.dart';
import 'package:pos_app/core/theme/app_colors.dart';
import 'package:pos_app/core/theme/app_spacing.dart';
import 'package:pos_app/core/theme/app_typography.dart';
import 'package:pos_app/core/widgets/category_avatar.dart';

/// Fila horizontal de chips para filtrar por categoría. `null` es "Todos".
class CategoryFilterChips extends StatelessWidget {
  const CategoryFilterChips({
    required this.selected,
    required this.onSelected,
    required this.categories,
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
          final isSelected = category?.id == selected?.id;
          return ChoiceChip(
            selected: isSelected,
            onSelected: (_) => onSelected(category),
            avatar: category == null
                ? null
                : CategoryGlyph(
                    category: category,
                    size: 18,
                    color: isSelected ? AppColors.onPrimary : null,
                  ),
            label: Text(category == null ? Strings.all : category.name),
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
