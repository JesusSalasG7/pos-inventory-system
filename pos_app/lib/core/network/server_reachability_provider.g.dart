// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server_reachability_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Indica si la última petición no pudo llegar al servidor.
///
/// Lo actualiza `ErrorInterceptor`; `OfflineBanner` lo muestra.

@ProviderFor(ServerOffline)
final serverOfflineProvider = ServerOfflineProvider._();

/// Indica si la última petición no pudo llegar al servidor.
///
/// Lo actualiza `ErrorInterceptor`; `OfflineBanner` lo muestra.
final class ServerOfflineProvider extends $NotifierProvider<ServerOffline, bool> {
  /// Indica si la última petición no pudo llegar al servidor.
  ///
  /// Lo actualiza `ErrorInterceptor`; `OfflineBanner` lo muestra.
  ServerOfflineProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'serverOfflineProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$serverOfflineHash();

  @$internal
  @override
  ServerOffline create() => ServerOffline();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<bool>(value));
  }
}

String _$serverOfflineHash() => r'b829a43a9a05d6801110ca586e183dec30d206e4';

/// Indica si la última petición no pudo llegar al servidor.
///
/// Lo actualiza `ErrorInterceptor`; `OfflineBanner` lo muestra.

abstract class _$ServerOffline extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element as $ClassProviderElement<AnyNotifier<bool, bool>, bool, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}
