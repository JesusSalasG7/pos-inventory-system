import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/features/credits/domain/credit_reminder_plan.dart';

import '../mocks/fake_repositories.dart';

void main() {
  final ana = customer(1, 'Ana', balance: '10');
  final luis = customer(2, 'Luis', balance: '5');
  // Lunes 12/10 a las 8:00 de Caracas.
  final now = DateTime(2026, 10, 12, 8);

  test('avisa a las 9:00 del día en que vence cada deuda', () {
    final plan = CreditReminderPlan.build(
      credits: [
        credit(1, ana, balance: '10', dueDate: DateTime(2026, 10, 15)),
        credit(2, luis, balance: '5', dueDate: DateTime(2026, 10, 12)),
      ],
      now: now,
    );

    expect(plan.dueReminders.map((r) => (r.customerName, r.at)), [
      ('Luis', DateTime(2026, 10, 12, 9)),
      ('Ana', DateTime(2026, 10, 15, 9)),
    ]);
    expect(plan.dueReminders.first.id, CreditReminderPlan.dueReminderBaseId + 2);
    expect(plan.overdue, isNull);
  });

  test('las deudas del mismo cliente con el mismo vencimiento van en un solo aviso', () {
    final plan = CreditReminderPlan.build(
      credits: [
        credit(1, ana, balance: '4', dueDate: DateTime(2026, 10, 15)),
        credit(2, ana, balance: '6', dueDate: DateTime(2026, 10, 15)),
      ],
      now: now,
    );

    expect(plan.dueReminders.single.amountUsd, dec('10'));
  });

  test('pasadas las 9:00 no se programa el aviso de hoy', () {
    final plan = CreditReminderPlan.build(
      credits: [credit(1, ana, balance: '10', dueDate: DateTime(2026, 10, 12))],
      now: DateTime(2026, 10, 12, 9, 30),
    );

    expect(plan.dueReminders, isEmpty);
    expect(plan.isEmpty, isTrue);
  });

  test('las vencidas se resumen en un recordatorio diario', () {
    final plan = CreditReminderPlan.build(
      credits: [
        credit(1, ana, balance: '10', dueDate: DateTime(2026, 10, 9), overdue: true),
        credit(2, ana, balance: '2', dueDate: DateTime(2026, 10, 10), overdue: true),
        credit(3, luis, balance: '5', dueDate: DateTime(2026, 10, 11)),
        credit(4, luis, balance: '1', dueDate: DateTime(2026, 10, 20)),
      ],
      now: now,
    );

    expect(plan.overdue!.customerCount, 2);
    expect(plan.overdue!.amountUsd, dec('17'));
    expect(plan.dueReminders.single.amountUsd, dec('1'));
  });
}
