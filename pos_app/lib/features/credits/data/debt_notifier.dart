import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pos_app/core/currency/money_formatter.dart';
import 'package:pos_app/core/l10n/strings.dart';
import 'package:pos_app/features/credits/domain/credit_reminder_plan.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Programa en el teléfono los avisos de deudas.
abstract interface class DebtNotifier {
  /// Reemplaza los avisos programados por los del plan.
  Future<void> apply(CreditReminderPlan plan);

  /// Se llama al tocar un aviso con la app abierta o en segundo plano.
  set onOpen(VoidCallback? callback);
}

/// Avisos con `flutter_local_notifications`. Suenan aunque la app esté
/// cerrada y se reprograman solos al reiniciar el teléfono.
class LocalDebtNotifier implements DebtNotifier {
  LocalDebtNotifier([FlutterLocalNotificationsPlugin? plugin])
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const String _channelId = 'debts';

  /// El negocio está en Venezuela: los avisos siguen la hora de Caracas.
  static const String _timeZone = 'America/Caracas';

  final FlutterLocalNotificationsPlugin _plugin;
  Future<bool>? _ready;
  VoidCallback? _onOpen;

  @override
  set onOpen(VoidCallback? callback) => _onOpen = callback;

  NotificationDetails get _details => const NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      Strings.debtChannelName,
      channelDescription: Strings.debtChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
    ),
  );

  /// Inicializa el plugin una sola vez. Devuelve `false` fuera de Android.
  Future<bool> _ensureReady() => _ready ??= () async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return false;
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation(_timeZone));
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
      onDidReceiveNotificationResponse: (_) => _onOpen?.call(),
    );
    return true;
  }();

  @override
  Future<void> apply(CreditReminderPlan plan) async {
    if (!await _ensureReady()) return;
    await _plugin.cancelAllPendingNotifications();
    if (plan.isEmpty) return;

    // Android 13+ pide permiso la primera vez; si lo niega, no se insiste.
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    final location = tz.getLocation(_timeZone);
    for (final reminder in plan.dueReminders) {
      final at = reminder.at;
      await _plugin.zonedSchedule(
        id: reminder.id,
        title: Strings.debtDueTitle,
        body: Strings.debtDueBody(reminder.customerName, MoneyFormatter.usd(reminder.amountUsd)),
        scheduledDate: tz.TZDateTime(location, at.year, at.month, at.day, at.hour),
        notificationDetails: _details,
        // Sin alarmas exactas: no requieren permiso especial y unos minutos
        // de diferencia no importan para un recordatorio de cobro.
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }

    final overdue = plan.overdue;
    if (overdue != null) {
      final now = tz.TZDateTime.now(location);
      var next = tz.TZDateTime(
        location,
        now.year,
        now.month,
        now.day,
        CreditReminderPlan.reminderHour,
      );
      if (!next.isAfter(now)) next = next.add(const Duration(days: 1));
      await _plugin.zonedSchedule(
        id: CreditReminderPlan.overdueSummaryId,
        title: Strings.overdueTitle,
        body: Strings.overdueBody(overdue.customerCount, MoneyFormatter.usd(overdue.amountUsd)),
        scheduledDate: next,
        notificationDetails: _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        // Se repite cada día a la misma hora hasta que se cobre o se reprograme.
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }
}

/// Notificador que solo recuerda el último plan. Para tests y plataformas sin avisos.
class InMemoryDebtNotifier implements DebtNotifier {
  CreditReminderPlan? lastPlan;
  VoidCallback? callback;

  @override
  set onOpen(VoidCallback? callback) => this.callback = callback;

  @override
  Future<void> apply(CreditReminderPlan plan) async => lastPlan = plan;
}
