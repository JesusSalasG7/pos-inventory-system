// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cash_session_repository_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(cashSessionRepository)
final cashSessionRepositoryProvider = CashSessionRepositoryProvider._();

final class CashSessionRepositoryProvider
    extends $FunctionalProvider<CashSessionRepository, CashSessionRepository, CashSessionRepository>
    with $Provider<CashSessionRepository> {
  CashSessionRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cashSessionRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cashSessionRepositoryHash();

  @$internal
  @override
  $ProviderElement<CashSessionRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CashSessionRepository create(Ref ref) {
    return cashSessionRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CashSessionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CashSessionRepository>(value),
    );
  }
}

String _$cashSessionRepositoryHash() => r'2f0db5071f260e879c2b938e5069b5ed5b3fc141';
