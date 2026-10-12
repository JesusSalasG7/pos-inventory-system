// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'credits_repository_impl.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(creditsRepository)
final creditsRepositoryProvider = CreditsRepositoryProvider._();

final class CreditsRepositoryProvider
    extends $FunctionalProvider<CreditsRepository, CreditsRepository, CreditsRepository>
    with $Provider<CreditsRepository> {
  CreditsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'creditsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$creditsRepositoryHash();

  @$internal
  @override
  $ProviderElement<CreditsRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CreditsRepository create(Ref ref) {
    return creditsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreditsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreditsRepository>(value),
    );
  }
}

String _$creditsRepositoryHash() => r'd73abd888b04c30f599b994514cce3e49efe857f';
