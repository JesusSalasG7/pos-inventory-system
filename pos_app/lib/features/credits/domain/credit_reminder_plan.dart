import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';
import 'package:pos_app/features/credits/domain/entities/credit.dart';

/// Aviso de que vence hoy la deuda de un cliente.
@immutable
class DueReminder {
  const DueReminder({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.amountUsd,
    required this.at,
  });

  /// Identificador de la notificación: estable para la misma deuda.
  final int id;
  final int customerId;
  final String customerName;

  /// Lo que vence ese día (las compras del cliente con el mismo plazo, sumadas).
  final Decimal amountUsd;

  /// Hora de Caracas en que suena el aviso, como fecha y hora de reloj.
  final DateTime at;
}

/// Recordatorio diario mientras haya deudas vencidas.
@immutable
class OverdueSummary {
  const OverdueSummary({required this.customerCount, required this.amountUsd});

  final int customerCount;
  final Decimal amountUsd;
}

/// Qué avisos de deudas deben quedar programados en el teléfono.
///
/// Es dominio puro: recibe las deudas pendientes y la hora actual de Caracas
/// (como fecha y hora de reloj) y no conoce el plugin de notificaciones.
@immutable
class CreditReminderPlan {
  const CreditReminderPlan({required this.dueReminders, this.overdue});

  /// Hora del día a la que suenan los avisos.
  static const int reminderHour = 9;

  /// Id fijo del recordatorio diario de deudas vencidas.
  static const int overdueSummaryId = 1;

  /// Los avisos de vencimiento usan ids a partir de aquí (más el id de la deuda).
  static const int dueReminderBaseId = 1000;

  final List<DueReminder> dueReminders;
  final OverdueSummary? overdue;

  bool get isEmpty => dueReminders.isEmpty && overdue == null;

  /// - Cada deuda que vence hoy (si aún no son las 9:00) o más adelante tiene
  ///   un aviso a las 9:00 de su último día. Las del mismo cliente con el
  ///   mismo vencimiento se juntan en un solo aviso.
  /// - Si hay deudas vencidas, un recordatorio diario a las 9:00 las resume.
  static CreditReminderPlan build({required List<Credit> credits, required DateTime now}) {
    final today = DateTime(now.year, now.month, now.day);
    final grouped = <(int, DateTime), List<Credit>>{};
    final overdueByCustomer = <int, Decimal>{};

    for (final credit in credits) {
      if (credit.isPaid) continue;
      final due = DateTime(credit.dueDate.year, credit.dueDate.month, credit.dueDate.day);
      if (credit.isOverdue || due.isBefore(today)) {
        overdueByCustomer.update(
          credit.customerId,
          (sum) => sum + credit.balanceUsd,
          ifAbsent: () => credit.balanceUsd,
        );
        continue;
      }
      final at = due.add(const Duration(hours: reminderHour));
      if (!at.isAfter(now)) continue;
      grouped.putIfAbsent((credit.customerId, due), () => []).add(credit);
    }

    final reminders = [
      for (final group in grouped.values)
        DueReminder(
          id: dueReminderBaseId + group.first.id,
          customerId: group.first.customerId,
          customerName: group.first.customerName,
          amountUsd: group.fold(Decimal.zero, (sum, credit) => sum + credit.balanceUsd),
          at: DateTime(
            group.first.dueDate.year,
            group.first.dueDate.month,
            group.first.dueDate.day,
            reminderHour,
          ),
        ),
    ]..sort((a, b) => a.at.compareTo(b.at));

    return CreditReminderPlan(
      dueReminders: reminders,
      overdue: overdueByCustomer.isEmpty
          ? null
          : OverdueSummary(
              customerCount: overdueByCustomer.length,
              amountUsd: overdueByCustomer.values.fold(Decimal.zero, (sum, value) => sum + value),
            ),
    );
  }
}
