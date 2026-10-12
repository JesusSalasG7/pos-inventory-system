// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credits_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Clientes con lo que deben en la tienda activa. Con `withDebt` solo los
/// que deben; con `onlyActive`, solo a los que se les puede vender a crédito.

@ProviderFor(customers)
final customersProvider = CustomersFamily._();

/// Clientes con lo que deben en la tienda activa. Con `withDebt` solo los
/// que deben; con `onlyActive`, solo a los que se les puede vender a crédito.

final class CustomersProvider
    extends
        $FunctionalProvider<AsyncValue<List<Customer>>, List<Customer>, FutureOr<List<Customer>>>
    with $FutureModifier<List<Customer>>, $FutureProvider<List<Customer>> {
  /// Clientes con lo que deben en la tienda activa. Con `withDebt` solo los
  /// que deben; con `onlyActive`, solo a los que se les puede vender a crédito.
  CustomersProvider._({
    required CustomersFamily super.from,
    required ({String search, bool withDebt, bool onlyActive}) super.argument,
  }) : super(
         retry: null,
         name: r'customersProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$customersHash();

  @override
  String toString() {
    return r'customersProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<Customer>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Customer>> create(Ref ref) {
    final argument = this.argument as ({String search, bool withDebt, bool onlyActive});
    return customers(
      ref,
      search: argument.search,
      withDebt: argument.withDebt,
      onlyActive: argument.onlyActive,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is CustomersProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$customersHash() => r'cb4e5ad8b89bc073d9b52d77b3031b770320bd66';

/// Clientes con lo que deben en la tienda activa. Con `withDebt` solo los
/// que deben; con `onlyActive`, solo a los que se les puede vender a crédito.

final class CustomersFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<Customer>>,
          ({String search, bool withDebt, bool onlyActive})
        > {
  CustomersFamily._()
    : super(
        retry: null,
        name: r'customersProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Clientes con lo que deben en la tienda activa. Con `withDebt` solo los
  /// que deben; con `onlyActive`, solo a los que se les puede vender a crédito.

  CustomersProvider call({String search = '', bool withDebt = false, bool onlyActive = false}) =>
      CustomersProvider._(
        argument: (search: search, withDebt: withDebt, onlyActive: onlyActive),
        from: this,
      );

  @override
  String toString() => r'customersProvider';
}

/// Un cliente con su saldo en la tienda activa y la tasa del BCV del día.

@ProviderFor(customer)
final customerProvider = CustomerFamily._();

/// Un cliente con su saldo en la tienda activa y la tasa del BCV del día.

final class CustomerProvider
    extends $FunctionalProvider<AsyncValue<Customer>, Customer, FutureOr<Customer>>
    with $FutureModifier<Customer>, $FutureProvider<Customer> {
  /// Un cliente con su saldo en la tienda activa y la tasa del BCV del día.
  CustomerProvider._({required CustomerFamily super.from, required int super.argument})
    : super(
        retry: null,
        name: r'customerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$customerHash();

  @override
  String toString() {
    return r'customerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Customer> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Customer> create(Ref ref) {
    final argument = this.argument as int;
    return customer(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CustomerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$customerHash() => r'7c61e372347c6c93affd3d5d154b4d17cee9269d';

/// Un cliente con su saldo en la tienda activa y la tasa del BCV del día.

final class CustomerFamily extends $Family with $FunctionalFamilyOverride<FutureOr<Customer>, int> {
  CustomerFamily._()
    : super(
        retry: null,
        name: r'customerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Un cliente con su saldo en la tienda activa y la tasa del BCV del día.

  CustomerProvider call(int customerId) => CustomerProvider._(argument: customerId, from: this);

  @override
  String toString() => r'customerProvider';
}

/// Compras a crédito de un cliente en la tienda activa, pendientes o pagadas.

@ProviderFor(customerCredits)
final customerCreditsProvider = CustomerCreditsFamily._();

/// Compras a crédito de un cliente en la tienda activa, pendientes o pagadas.

final class CustomerCreditsProvider
    extends $FunctionalProvider<AsyncValue<List<Credit>>, List<Credit>, FutureOr<List<Credit>>>
    with $FutureModifier<List<Credit>>, $FutureProvider<List<Credit>> {
  /// Compras a crédito de un cliente en la tienda activa, pendientes o pagadas.
  CustomerCreditsProvider._({
    required CustomerCreditsFamily super.from,
    required (int, CreditStatus) super.argument,
  }) : super(
         retry: null,
         name: r'customerCreditsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$customerCreditsHash();

  @override
  String toString() {
    return r'customerCreditsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<Credit>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Credit>> create(Ref ref) {
    final argument = this.argument as (int, CreditStatus);
    return customerCredits(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is CustomerCreditsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$customerCreditsHash() => r'b50811329f03ce0b92dc7e02a2e27f8891fb8cb1';

/// Compras a crédito de un cliente en la tienda activa, pendientes o pagadas.

final class CustomerCreditsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Credit>>, (int, CreditStatus)> {
  CustomerCreditsFamily._()
    : super(
        retry: null,
        name: r'customerCreditsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Compras a crédito de un cliente en la tienda activa, pendientes o pagadas.

  CustomerCreditsProvider call(int customerId, CreditStatus status) =>
      CustomerCreditsProvider._(argument: (customerId, status), from: this);

  @override
  String toString() => r'customerCreditsProvider';
}

/// Abonos de un cliente en la tienda activa, del más reciente al más antiguo.

@ProviderFor(customerPayments)
final customerPaymentsProvider = CustomerPaymentsFamily._();

/// Abonos de un cliente en la tienda activa, del más reciente al más antiguo.

final class CustomerPaymentsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CreditPayment>>,
          List<CreditPayment>,
          FutureOr<List<CreditPayment>>
        >
    with $FutureModifier<List<CreditPayment>>, $FutureProvider<List<CreditPayment>> {
  /// Abonos de un cliente en la tienda activa, del más reciente al más antiguo.
  CustomerPaymentsProvider._({
    required CustomerPaymentsFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'customerPaymentsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$customerPaymentsHash();

  @override
  String toString() {
    return r'customerPaymentsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<CreditPayment>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<CreditPayment>> create(Ref ref) {
    final argument = this.argument as int;
    return customerPayments(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CustomerPaymentsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$customerPaymentsHash() => r'df805192ee2e75042c9717f4f07b6a3299318b5c';

/// Abonos de un cliente en la tienda activa, del más reciente al más antiguo.

final class CustomerPaymentsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<CreditPayment>>, int> {
  CustomerPaymentsFamily._()
    : super(
        retry: null,
        name: r'customerPaymentsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Abonos de un cliente en la tienda activa, del más reciente al más antiguo.

  CustomerPaymentsProvider call(int customerId) =>
      CustomerPaymentsProvider._(argument: customerId, from: this);

  @override
  String toString() => r'customerPaymentsProvider';
}

/// Deudas con saldo de la tienda activa. Con ellas se programan los avisos
/// del teléfono y se arma la tarjeta de Inicio.

@ProviderFor(pendingCredits)
final pendingCreditsProvider = PendingCreditsProvider._();

/// Deudas con saldo de la tienda activa. Con ellas se programan los avisos
/// del teléfono y se arma la tarjeta de Inicio.

final class PendingCreditsProvider
    extends $FunctionalProvider<AsyncValue<List<Credit>>, List<Credit>, FutureOr<List<Credit>>>
    with $FutureModifier<List<Credit>>, $FutureProvider<List<Credit>> {
  /// Deudas con saldo de la tienda activa. Con ellas se programan los avisos
  /// del teléfono y se arma la tarjeta de Inicio.
  PendingCreditsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingCreditsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingCreditsHash();

  @$internal
  @override
  $FutureProviderElement<List<Credit>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<Credit>> create(Ref ref) {
    return pendingCredits(ref);
  }
}

String _$pendingCreditsHash() => r'53501915f7fc3152c17444f00cac6148a0e1cbcc';

/// Altas, cambios y abonos de clientes. Tras cada operación invalida lo que
/// depende de ella (saldos, listas, avisos y la caja donde entró el abono).
///
/// `keepAlive`: ninguna pantalla lo escucha, solo lo leen al guardar. Si se
/// destruyera solo, lo haría a mitad de la petición y la pantalla quedaría
/// esperando para siempre aunque el backend ya hubiera guardado.

@ProviderFor(CreditsController)
final creditsControllerProvider = CreditsControllerProvider._();

/// Altas, cambios y abonos de clientes. Tras cada operación invalida lo que
/// depende de ella (saldos, listas, avisos y la caja donde entró el abono).
///
/// `keepAlive`: ninguna pantalla lo escucha, solo lo leen al guardar. Si se
/// destruyera solo, lo haría a mitad de la petición y la pantalla quedaría
/// esperando para siempre aunque el backend ya hubiera guardado.
final class CreditsControllerProvider extends $NotifierProvider<CreditsController, void> {
  /// Altas, cambios y abonos de clientes. Tras cada operación invalida lo que
  /// depende de ella (saldos, listas, avisos y la caja donde entró el abono).
  ///
  /// `keepAlive`: ninguna pantalla lo escucha, solo lo leen al guardar. Si se
  /// destruyera solo, lo haría a mitad de la petición y la pantalla quedaría
  /// esperando para siempre aunque el backend ya hubiera guardado.
  CreditsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'creditsControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$creditsControllerHash();

  @$internal
  @override
  CreditsController create() => CreditsController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<void>(value));
  }
}

String _$creditsControllerHash() => r'bcaa0e099983654dd262903dba1c7e6d212b63b2';

/// Altas, cambios y abonos de clientes. Tras cada operación invalida lo que
/// depende de ella (saldos, listas, avisos y la caja donde entró el abono).
///
/// `keepAlive`: ninguna pantalla lo escucha, solo lo leen al guardar. Si se
/// destruyera solo, lo haría a mitad de la petición y la pantalla quedaría
/// esperando para siempre aunque el backend ya hubiera guardado.

abstract class _$CreditsController extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element as $ClassProviderElement<AnyNotifier<void, void>, void, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
