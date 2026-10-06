import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/core/l10n/strings.dart';
import 'package:pos_app/core/theme/app_colors.dart';
import 'package:pos_app/core/theme/app_spacing.dart';
import 'package:pos_app/core/theme/app_typography.dart';
import 'package:pos_app/core/widgets/primary_button.dart';
import 'package:pos_app/features/auth/presentation/providers/session_controller.dart';
import 'package:pos_app/features/auth/presentation/screens/auth_scaffold.dart';

/// Pantalla de arranque: se ve mientras se restaura la sesión. Si no se puede
/// conectar, ofrece reintentar o salir.
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionControllerProvider);
    final failure = session.status == SessionStatus.error ? session.failure : null;
    final controller = ref.read(sessionControllerProvider.notifier);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              children: [
                const Spacer(),
                const BrandMark(size: 96),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  Strings.appName,
                  textAlign: TextAlign.center,
                  style: AppTypography.headline.copyWith(color: AppColors.onPrimary),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  Strings.appTagline,
                  textAlign: TextAlign.center,
                  style: AppTypography.body.copyWith(color: AppColors.onPrimary),
                ),
                const Spacer(),
                if (failure == null) ...[
                  const SizedBox.square(
                    dimension: 28,
                    child: CircularProgressIndicator(strokeWidth: 3, color: AppColors.onPrimary),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    Strings.startingUp,
                    style: AppTypography.bodySmall.copyWith(color: AppColors.onPrimary),
                  ),
                ] else ...[
                  Text(
                    Strings.startupErrorTitle,
                    textAlign: TextAlign.center,
                    style: AppTypography.title.copyWith(color: AppColors.onPrimary),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    failure.message,
                    textAlign: TextAlign.center,
                    style: AppTypography.body.copyWith(color: AppColors.onPrimary),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  PrimaryButton(
                    label: Strings.retry,
                    icon: Icons.refresh_rounded,
                    tone: ButtonTone.success,
                    onPressed: controller.bootstrap,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextButton(
                    onPressed: controller.logout,
                    style: TextButton.styleFrom(foregroundColor: AppColors.onPrimary),
                    child: const Text(Strings.signOut),
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
