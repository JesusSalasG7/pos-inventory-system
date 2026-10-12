import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:pos_app/core/formatting/date_formatter.dart';
import 'package:pos_app/features/credits/data/debt_notifier.dart';
import 'package:pos_app/features/credits/domain/credit_reminder_plan.dart';
import 'package:pos_app/features/credits/domain/entities/credit.dart';
import 'package:pos_app/features/credits/presentation/providers/credits_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'credit_reminders_provider.g.dart';

@Riverpod(keepAlive: true)
DebtNotifier debtNotifications(Ref ref) => LocalDebtNotifier();

/// Mantiene los avisos del teléfono al día con las deudas pendientes de la
/// tienda activa. Cada vez que cambian (venta a crédito, abono, cambio de
/// tienda, vuelta a primer plano) se reprograman todos.
///
/// Lo mantiene vivo `MainShell` mientras la sesión está lista.
@Riverpod(keepAlive: true)
class CreditReminders extends _$CreditReminders {
  @override
  CreditReminderPlan? build() {
    ref.listen(pendingCreditsProvider, (_, next) {
      final credits = next.value;
      if (credits != null) unawaited(_apply(credits));
    }, fireImmediately: true);
    return null;
  }

  Future<void> _apply(List<Credit> credits) async {
    final plan = CreditReminderPlan.build(
      credits: credits,
      now: _wallClock(DateFormatter.nowInCaracas()),
    );
    state = plan;
    try {
      await ref.read(debtNotificationsProvider).apply(plan);
    } on Object catch (error) {
      // Un fallo del sistema de avisos no debe romper la app.
      debugPrint('No se pudieron programar los avisos de deudas: $error');
    }
  }

  /// Fecha y hora de reloj de Caracas, sin zona: así la compara el plan.
  static DateTime _wallClock(DateTime caracas) =>
      DateTime(caracas.year, caracas.month, caracas.day, caracas.hour, caracas.minute);
}
