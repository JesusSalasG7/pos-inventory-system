import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pos_app/core/l10n/strings.dart';
import 'package:pos_app/core/network/server_reachability_provider.dart';
import 'package:pos_app/core/theme/app_colors.dart';
import 'package:pos_app/core/theme/app_spacing.dart';
import 'package:pos_app/core/theme/app_typography.dart';

/// Franja de aviso que aparece cuando la última petición no llegó al servidor.
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({this.onRetry, super.key});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offline = ref.watch(serverOfflineProvider);
    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      alignment: Alignment.topCenter,
      child: offline ? _OfflineBar(onRetry: onRetry) : const SizedBox(width: double.infinity),
    );
  }
}

class _OfflineBar extends StatelessWidget {
  const _OfflineBar({this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      child: Container(
        width: double.infinity,
        color: AppColors.warningSoft,
        padding: const EdgeInsets.only(left: AppSpacing.lg, right: AppSpacing.sm),
        constraints: const BoxConstraints(minHeight: AppSpacing.minTouchTarget),
        child: Row(
          children: [
            const Icon(Icons.wifi_off_rounded, color: AppColors.warning, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                Strings.offlineBanner,
                style: AppTypography.label.copyWith(fontSize: 13, color: AppColors.warning),
              ),
            ),
            if (onRetry != null)
              TextButton(
                onPressed: onRetry,
                style: TextButton.styleFrom(foregroundColor: AppColors.warning),
                child: const Text(Strings.retry),
              ),
          ],
        ),
      ),
    );
  }
}
