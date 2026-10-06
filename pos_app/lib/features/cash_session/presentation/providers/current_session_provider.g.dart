// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'current_session_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Caja abierta del usuario; `null` si no tiene ninguna.
///
/// El backend permite una sola caja abierta por usuario, en cualquier
/// sucursal: puede pertenecer a una distinta de la activa.

@ProviderFor(CurrentSession)
final currentSessionProvider = CurrentSessionProvider._();

/// Caja abierta del usuario; `null` si no tiene ninguna.
///
/// El backend permite una sola caja abierta por usuario, en cualquier
/// sucursal: puede pertenecer a una distinta de la activa.
final class CurrentSessionProvider extends $AsyncNotifierProvider<CurrentSession, CashSession?> {
  /// Caja abierta del usuario; `null` si no tiene ninguna.
  ///
  /// El backend permite una sola caja abierta por usuario, en cualquier
  /// sucursal: puede pertenecer a una distinta de la activa.
  CurrentSessionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentSessionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentSessionHash();

  @$internal
  @override
  CurrentSession create() => CurrentSession();
}

String _$currentSessionHash() => r'a1928efef07877a468b9baf99259f61849612908';

/// Caja abierta del usuario; `null` si no tiene ninguna.
///
/// El backend permite una sola caja abierta por usuario, en cualquier
/// sucursal: puede pertenecer a una distinta de la activa.

abstract class _$CurrentSession extends $AsyncNotifier<CashSession?> {
  FutureOr<CashSession?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<CashSession?>, CashSession?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<CashSession?>, CashSession?>,
              AsyncValue<CashSession?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Egresos de una caja.

@ProviderFor(sessionExpenses)
final sessionExpensesProvider = SessionExpensesFamily._();

/// Egresos de una caja.

final class SessionExpensesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CashExpense>>,
          List<CashExpense>,
          FutureOr<List<CashExpense>>
        >
    with $FutureModifier<List<CashExpense>>, $FutureProvider<List<CashExpense>> {
  /// Egresos de una caja.
  SessionExpensesProvider._({
    required SessionExpensesFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'sessionExpensesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$sessionExpensesHash();

  @override
  String toString() {
    return r'sessionExpensesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<CashExpense>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<CashExpense>> create(Ref ref) {
    final argument = this.argument as int;
    return sessionExpenses(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SessionExpensesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$sessionExpensesHash() => r'9072e47539da37be4d01ba06e8784eb7d2cf6e1d';

/// Egresos de una caja.

final class SessionExpensesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<CashExpense>>, int> {
  SessionExpensesFamily._()
    : super(
        retry: null,
        name: r'sessionExpensesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Egresos de una caja.

  SessionExpensesProvider call(int sessionId) =>
      SessionExpensesProvider._(argument: sessionId, from: this);

  @override
  String toString() => r'sessionExpensesProvider';
}

/// Arqueo de una caja: efectivo esperado según ventas y egresos.

@ProviderFor(sessionSummary)
final sessionSummaryProvider = SessionSummaryFamily._();

/// Arqueo de una caja: efectivo esperado según ventas y egresos.

final class SessionSummaryProvider
    extends
        $FunctionalProvider<
          AsyncValue<CashCountSummary>,
          CashCountSummary,
          FutureOr<CashCountSummary>
        >
    with $FutureModifier<CashCountSummary>, $FutureProvider<CashCountSummary> {
  /// Arqueo de una caja: efectivo esperado según ventas y egresos.
  SessionSummaryProvider._({required SessionSummaryFamily super.from, required int super.argument})
    : super(
        retry: null,
        name: r'sessionSummaryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sessionSummaryHash();

  @override
  String toString() {
    return r'sessionSummaryProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<CashCountSummary> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<CashCountSummary> create(Ref ref) {
    final argument = this.argument as int;
    return sessionSummary(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SessionSummaryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$sessionSummaryHash() => r'622124f0be65a89a66da02560fab84d10f887dac';

/// Arqueo de una caja: efectivo esperado según ventas y egresos.

final class SessionSummaryFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<CashCountSummary>, int> {
  SessionSummaryFamily._()
    : super(
        retry: null,
        name: r'sessionSummaryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Arqueo de una caja: efectivo esperado según ventas y egresos.

  SessionSummaryProvider call(int sessionId) =>
      SessionSummaryProvider._(argument: sessionId, from: this);

  @override
  String toString() => r'sessionSummaryProvider';
}

/// Historial de cajas de la sucursal activa, cargado página a página.

@ProviderFor(CashHistory)
final cashHistoryProvider = CashHistoryProvider._();

/// Historial de cajas de la sucursal activa, cargado página a página.
final class CashHistoryProvider
    extends $AsyncNotifierProvider<CashHistory, PagedList<CashSession>> {
  /// Historial de cajas de la sucursal activa, cargado página a página.
  CashHistoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cashHistoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cashHistoryHash();

  @$internal
  @override
  CashHistory create() => CashHistory();
}

String _$cashHistoryHash() => r'd68286a66f8e811455023639afd91d136d502c39';

/// Historial de cajas de la sucursal activa, cargado página a página.

abstract class _$CashHistory extends $AsyncNotifier<PagedList<CashSession>> {
  FutureOr<PagedList<CashSession>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<PagedList<CashSession>>, PagedList<CashSession>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<PagedList<CashSession>>, PagedList<CashSession>>,
              AsyncValue<PagedList<CashSession>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
