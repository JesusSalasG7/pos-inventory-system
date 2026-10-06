import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/core/l10n/strings.dart';
import 'package:pos_app/core/theme/app_colors.dart';
import 'package:pos_app/core/theme/app_spacing.dart';
import 'package:pos_app/core/widgets/empty_state.dart';
import 'package:pos_app/core/widgets/primary_button.dart';
import 'package:pos_app/features/auth/presentation/providers/session_controller.dart';

/// Aviso para quien no puede operar: su sucursal está inactiva o, siendo
/// SUPERVISOR, el negocio todavía no tiene ninguna.
class BranchUnavailableScreen extends ConsumerWidget {
  const BranchUnavailableScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(sessionControllerProvider.notifier);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              const Expanded(
                child: EmptyState(
                  icon: Icons.store_mall_directory_outlined,
                  title: Strings.branchUnavailableTitle,
                  message: Strings.branchUnavailableMessage,
                  iconColor: AppColors.warning,
                  iconBackground: AppColors.warningSoft,
                ),
              ),
              PrimaryButton(
                label: Strings.retry,
                icon: Icons.refresh_rounded,
                onPressed: controller.bootstrap,
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton(onPressed: controller.logout, child: const Text(Strings.signOut)),
            ],
          ),
        ),
      ),
    );
  }
}
