// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'branches_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Todas las tiendas del negocio, también las inactivas. Concentra las
/// operaciones de un MANAGER sobre ellas.

@ProviderFor(AllBranches)
final allBranchesProvider = AllBranchesProvider._();

/// Todas las tiendas del negocio, también las inactivas. Concentra las
/// operaciones de un MANAGER sobre ellas.
final class AllBranchesProvider extends $AsyncNotifierProvider<AllBranches, List<Branch>> {
  /// Todas las tiendas del negocio, también las inactivas. Concentra las
  /// operaciones de un MANAGER sobre ellas.
  AllBranchesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allBranchesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allBranchesHash();

  @$internal
  @override
  AllBranches create() => AllBranches();
}

String _$allBranchesHash() => r'31e0ba22f8c826f43819b4fe9a60bfba3f886aac';

/// Todas las tiendas del negocio, también las inactivas. Concentra las
/// operaciones de un MANAGER sobre ellas.

abstract class _$AllBranches extends $AsyncNotifier<List<Branch>> {
  FutureOr<List<Branch>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Branch>>, List<Branch>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Branch>>, List<Branch>>,
              AsyncValue<List<Branch>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
