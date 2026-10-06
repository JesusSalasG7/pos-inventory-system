import 'package:flutter/material.dart';
import 'package:pos_app/core/currency/money_formatter.dart';
import 'package:pos_app/core/formatting/date_formatter.dart';
import 'package:pos_app/core/l10n/strings.dart';
import 'package:pos_app/core/theme/app_colors.dart';
import 'package:pos_app/core/theme/app_spacing.dart';
import 'package:pos_app/core/theme/app_typography.dart';
import 'package:pos_app/features/exchange_rate/presentation/providers/rate_change_notice_provider.dart';

/// Aviso de que la tasa activa cambió: la tasa nueva, su origen y el día al
/// que corresponde, y la tasa anterior si se conoce.
class RateChangeDialog extends StatelessWidget {
  const RateChangeDialog({required this.notice, super.key});

  final RateChangeNotice notice;

  @override
  Widget build(BuildContext context) {
    final rate = notice.current;
    final previous = notice.previousRate;
    return AlertDialog(
      icon: Container(
        width: 64,
        height: 64,
        decoration: const BoxDecoration(color: AppColors.accentSoft, shape: BoxShape.circle),
        child: const Icon(Icons.currency_exchange_rounded, color: AppColors.onAccent, size: 30),
      ),
      title: const Text(Strings.rateChangedTitle, textAlign: TextAlign.center),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${Strings.rateUnit} ${MoneyFormatter.rate(rate.rate)}',
            textAlign: TextAlign.center,
            style: AppTypography.amount(30),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            Strings.rateDayLine(rate.source, DateFormatter.calendarDate(rate.day)),
            textAlign: TextAlign.center,
            style: AppTypography.subtitle.copyWith(color: AppColors.primaryDark),
          ),
          if (previous != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              Strings.previousRate(MoneyFormatter.rate(previous)),
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall,
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Text(
            Strings.rateChangedNote,
            textAlign: TextAlign.center,
            style: AppTypography.bodySmall,
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(Strings.understood),
        ),
      ],
    );
  }
}
