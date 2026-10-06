import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_app/app/router/route_names.dart';
import 'package:pos_app/core/l10n/strings.dart';
import 'package:pos_app/core/session/active_branch_provider.dart';
import 'package:pos_app/core/session/current_user_provider.dart';
import 'package:pos_app/core/theme/app_colors.dart';
import 'package:pos_app/core/theme/app_radius.dart';
import 'package:pos_app/core/theme/app_spacing.dart';
import 'package:pos_app/core/theme/app_typography.dart';
import 'package:pos_app/core/widgets/confirm_dialog.dart';
import 'package:pos_app/features/auth/presentation/providers/session_controller.dart';

/// Pestaña "Más": la cuenta y las opciones secundarias.
// TODO(fase-6): historial de ventas, tasa de cambio, reportes y administración.
class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final confirmed = await showConfirmDialog(
      context,
      title: Strings.signOutTitle,
      message: Strings.signOutMessage,
      confirmLabel: Strings.signOut,
      isDestructive: true,
    );
    if (confirmed) await ref.read(sessionControllerProvider.notifier).logout();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final branch = ref.watch(activeBranchProvider);
    final branchCount = ref.watch(
      sessionControllerProvider.select((session) => session.branches.length),
    );
    final canChangeBranch = (user?.hasAllBranchesAccess ?? false) && branchCount > 1;

    return Scaffold(
      appBar: AppBar(title: const Text(Strings.navMore)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          if (user != null)
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.lgAll,
                boxShadow: AppColors.cardShadow,
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: AppColors.primarySoft,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person_rounded, color: AppColors.primaryDark, size: 30),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.fullName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.title,
                        ),
                        Text(
                          '${Strings.role(user.role)} · ${user.username}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodySmall,
                        ),
                        Text(
                          user.hasAllBranchesAccess
                              ? Strings.allBranches
                              : (branch?.name ?? Strings.noBranch),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.lgAll,
              boxShadow: AppColors.cardShadow,
            ),
            clipBehavior: Clip.antiAlias,
            child: Material(
              type: MaterialType.transparency,
              child: Column(
                children: [
                  if (canChangeBranch)
                    _MoreTile(
                      icon: Icons.storefront_rounded,
                      label: Strings.changeBranch,
                      detail: branch?.name,
                      onTap: ref.read(sessionControllerProvider.notifier).requestBranchChange,
                    ),
                  _MoreTile(
                    icon: Icons.currency_exchange_rounded,
                    label: Strings.exchangeRateTitle,
                    onTap: () => context.push(RouteNames.exchangeRate),
                  ),
                  _MoreTile(
                    icon: Icons.history_rounded,
                    label: Strings.cashHistory,
                    onTap: () => context.push(RouteNames.cashHistory),
                  ),
                  if (kDebugMode)
                    _MoreTile(
                      icon: Icons.palette_outlined,
                      label: Strings.designPreviewEntry,
                      onTap: () => context.push(RouteNames.designPreview),
                    ),
                  _MoreTile(
                    icon: Icons.logout_rounded,
                    label: Strings.signOut,
                    color: AppColors.error,
                    onTap: () => _confirmSignOut(context, ref),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MoreTile extends StatelessWidget {
  const _MoreTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.detail,
    this.color = AppColors.textPrimary,
  });

  final IconData icon;
  final String label;
  final String? detail;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      minTileHeight: 60,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      leading: Icon(icon, color: color),
      title: Text(label, style: AppTypography.subtitle.copyWith(color: color)),
      subtitle: detail == null ? null : Text(detail!, style: AppTypography.bodySmall),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }
}
