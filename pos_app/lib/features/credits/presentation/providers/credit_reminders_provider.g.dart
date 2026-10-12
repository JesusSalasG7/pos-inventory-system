// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credit_reminders_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(debtNotifications)
final debtNotificationsProvider = DebtNotificationsProvider._();

final class DebtNotificationsProvider
    extends $FunctionalProvider<DebtNotifier, DebtNotifier, DebtNotifier>
    with $Provider<DebtNotifier> {
  DebtNotificationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'debtNotificationsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$debtNotificationsHash();

  @$internal
  @override
  $ProviderElement<DebtNotifier> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DebtNotifier create(Ref ref) {
    return debtNotifications(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DebtNotifier value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DebtNotifier>(value),
    );
  }
}

String _$debtNotificationsHash() => r'1494d096f11b9833aea9070eb52822b74175c5dc';

/// Mantiene los avisos del teléfono al día con las deudas pendientes de la
/// tienda activa. Cada vez que cambian (venta a crédito, abono, cambio de
/// tienda, vuelta a primer plano) se reprograman todos.
///
/// Lo mantiene vivo `MainShell` mientras la sesión está lista.

@ProviderFor(CreditReminders)
final creditRemindersProvider = CreditRemindersProvider._();

/// Mantiene los avisos del teléfono al día con las deudas pendientes de la
/// tienda activa. Cada vez que cambian (venta a crédito, abono, cambio de
/// tienda, vuelta a primer plano) se reprograman todos.
///
/// Lo mantiene vivo `MainShell` mientras la sesión está lista.
final class CreditRemindersProvider
    extends $NotifierProvider<CreditReminders, CreditReminderPlan?> {
  /// Mantiene los avisos del teléfono al día con las deudas pendientes de la
  /// tienda activa. Cada vez que cambian (venta a crédito, abono, cambio de
  /// tienda, vuelta a primer plano) se reprograman todos.
  ///
  /// Lo mantiene vivo `MainShell` mientras la sesión está lista.
  CreditRemindersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'creditRemindersProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$creditRemindersHash();

  @$internal
  @override
  CreditReminders create() => CreditReminders();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreditReminderPlan? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreditReminderPlan?>(value),
    );
  }
}

String _$creditRemindersHash() => r'3aee3fd5ab4da36b410aebb7eefc50dcef246efa';

/// Mantiene los avisos del teléfono al día con las deudas pendientes de la
/// tienda activa. Cada vez que cambian (venta a crédito, abono, cambio de
/// tienda, vuelta a primer plano) se reprograman todos.
///
/// Lo mantiene vivo `MainShell` mientras la sesión está lista.

abstract class _$CreditReminders extends $Notifier<CreditReminderPlan?> {
  CreditReminderPlan? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<CreditReminderPlan?, CreditReminderPlan?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CreditReminderPlan?, CreditReminderPlan?>,
              CreditReminderPlan?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
