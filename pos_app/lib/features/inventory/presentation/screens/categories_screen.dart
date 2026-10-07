import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/core/domain/category.dart';
import 'package:pos_app/core/errors/failure.dart';
import 'package:pos_app/core/l10n/strings.dart';
import 'package:pos_app/core/theme/app_spacing.dart';
import 'package:pos_app/core/theme/app_typography.dart';
import 'package:pos_app/core/widgets/async_value_view.dart';
import 'package:pos_app/core/widgets/category_avatar.dart';
import 'package:pos_app/core/widgets/empty_state.dart';
import 'package:pos_app/core/widgets/section_card.dart';
import 'package:pos_app/features/inventory/presentation/providers/inventory_providers.dart';
import 'package:pos_app/features/inventory/presentation/widgets/category_dialog.dart';

/// Administración de categorías (solo MANAGER): crear, cambiar nombre y
/// sticker, y activar o desactivar. No se borran.
class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  Future<void> _edit(BuildContext context, {ProductCategory? category}) async {
    final saved = await showCategoryDialog(context, category: category);
    if (saved == null || !context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(category == null ? Strings.categoryCreated : Strings.categoryRenamed)),
    );
  }

  Future<void> _setActive(
    BuildContext context,
    WidgetRef ref,
    ProductCategory category, {
    required bool active,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(categoriesProvider.notifier).setActive(category.id, active: active);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(active ? Strings.categoryActivated : Strings.categoryDeactivated)),
        );
    } on Failure catch (failure) {
      messenger.showSnackBar(SnackBar(content: Text(failure.message)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(Strings.categoriesTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text(Strings.newCategory),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(categoriesProvider.future),
        child: AsyncValueView<List<ProductCategory>>(
          value: categories,
          onRetry: () => ref.invalidate(categoriesProvider),
          isEmpty: (items) => items.isEmpty,
          empty: const ScrollableEmptyState(
            icon: Icons.category_outlined,
            title: Strings.emptyCategoriesTitle,
            message: Strings.emptyCategoriesMessage,
          ),
          data: (items) => ListView.separated(
            // Deja sitio al botón flotante.
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 96),
            itemCount: items.length + 1,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, index) {
              if (index == 0) return Text(Strings.categoriesHint, style: AppTypography.bodySmall);
              final category = items[index - 1];
              return SectionCard(
                key: ValueKey(category.id),
                onTap: () => _edit(context, category: category),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    Opacity(
                      opacity: category.active ? 1 : 0.5,
                      child: CategoryAvatar(category: category),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.subtitle,
                          ),
                          if (!category.active)
                            Text(Strings.inactiveCategory, style: AppTypography.bodySmall),
                        ],
                      ),
                    ),
                    Switch(
                      value: category.active,
                      onChanged: (active) => _setActive(context, ref, category, active: active),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
