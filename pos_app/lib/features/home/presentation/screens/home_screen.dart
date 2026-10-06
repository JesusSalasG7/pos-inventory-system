import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/core/l10n/strings.dart';
import 'package:pos_app/core/session/current_user_provider.dart';
import 'package:pos_app/core/theme/app_colors.dart';
import 'package:pos_app/core/theme/app_radius.dart';
import 'package:pos_app/core/theme/app_spacing.dart';
import 'package:pos_app/core/theme/app_typography.dart';
import 'package:pos_app/core/widgets/connected_branch_header.dart';
import 'package:pos_app/core/widgets/offline_banner.dart';
import 'package:pos_app/features/exchange_rate/presentation/providers/active_rate_provider.dart';

/// Inicio. De momento saluda y confirma la sucursal.
// TODO(fase-3): ventas del día, tarjeta de caja, gasto rápido, stock mínimo y tasa vs BCV.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final firstName = (user?.fullName ?? '').trim().split(RegExp(r'\s+')).first;

    return Scaffold(
      appBar: const ConnectedBranchHeader(),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.read(activeRateProvider.notifier).refresh(),
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.lg),
                children: [
                  Text(
                    Strings.greeting(firstName.isEmpty ? (user?.username ?? '') : firstName),
                    style: AppTypography.headline,
                  ),
                  if (user != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: const BoxDecoration(
                          color: AppColors.accentSoft,
                          borderRadius: AppRadius.pillAll,
                        ),
                        child: Text(
                          Strings.role(user.role),
                          style: AppTypography.label.copyWith(
                            fontSize: 13,
                            color: AppColors.onAccent,
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xl),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppRadius.lgAll,
                      boxShadow: AppColors.cardShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: const BoxDecoration(
                            color: AppColors.primarySoft,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check_rounded,
                            color: AppColors.primaryDark,
                            size: 30,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(Strings.homeReadyTitle, style: AppTypography.title),
                        const SizedBox(height: AppSpacing.xs),
                        Text(Strings.homeReadyMessage, style: AppTypography.bodySmall),
                      ],
                    ),
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
