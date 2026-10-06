import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/core/domain/branch.dart';
import 'package:pos_app/core/l10n/strings.dart';
import 'package:pos_app/core/session/active_branch_provider.dart';
import 'package:pos_app/core/theme/app_colors.dart';
import 'package:pos_app/core/theme/app_radius.dart';
import 'package:pos_app/core/theme/app_spacing.dart';
import 'package:pos_app/core/theme/app_typography.dart';
import 'package:pos_app/features/auth/presentation/providers/session_controller.dart';
import 'package:pos_app/features/auth/presentation/screens/auth_scaffold.dart';

/// Selector de sucursal para un MANAGER con acceso a todas y varias sedes.
/// Muestra el `name` de cada sucursal en tarjetas grandes.
class BranchPickerScreen extends ConsumerWidget {
  const BranchPickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final branches = ref.watch(sessionControllerProvider.select((session) => session.branches));
    final current = ref.watch(activeBranchProvider);
    final controller = ref.read(sessionControllerProvider.notifier);

    return PopScope(
      // El botón atrás del sistema cancela el cambio si ya había una sede elegida.
      canPop: false,
      onPopInvokedWithResult: (_, _) => controller.cancelBranchChange(),
      child: AuthScaffold(
        title: Strings.pickBranchTitle,
        subtitle: Strings.pickBranchSubtitle,
        leading: current == null
            ? null
            : IconButton(
                tooltip: Strings.cancel,
                onPressed: controller.cancelBranchChange,
                icon: const Icon(Icons.arrow_back_rounded, color: AppColors.onPrimary),
              ),
        child: ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.xl),
          itemCount: branches.length + 1,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (context, index) {
            if (index == branches.length) {
              return Center(
                child: TextButton(onPressed: controller.logout, child: const Text(Strings.signOut)),
              );
            }
            final branch = branches[index];
            return _BranchCard(
              branch: branch,
              isCurrent: branch.code == current?.code,
              onTap: () => controller.selectBranch(branch),
            );
          },
        ),
      ),
    );
  }
}

class _BranchCard extends StatelessWidget {
  const _BranchCard({required this.branch, required this.isCurrent, required this.onTap});

  final Branch branch;
  final bool isCurrent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isCurrent ? AppColors.primarySoft : AppColors.surface,
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: isCurrent ? AppColors.primary : Colors.transparent, width: 2),
        boxShadow: AppColors.cardShadow,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: AppRadius.lgAll,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: AppColors.accentSoft,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.storefront_rounded, color: AppColors.onAccent, size: 28),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        branch.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.title,
                      ),
                      Text(
                        isCurrent ? '${branch.code} · ${Strings.currentBranch}' : branch.code,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodySmall,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
