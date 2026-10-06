// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rate_change_notice_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(rateNoticeStorage)
final rateNoticeStorageProvider = RateNoticeStorageProvider._();

final class RateNoticeStorageProvider
    extends $FunctionalProvider<RateNoticeStorage, RateNoticeStorage, RateNoticeStorage>
    with $Provider<RateNoticeStorage> {
  RateNoticeStorageProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rateNoticeStorageProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rateNoticeStorageHash();

  @$internal
  @override
  $ProviderElement<RateNoticeStorage> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  RateNoticeStorage create(Ref ref) {
    return rateNoticeStorage(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RateNoticeStorage value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RateNoticeStorage>(value),
    );
  }
}

String _$rateNoticeStorageHash() => r'b79dfd16e43671070a30074a6bdb44cae9589fa6';

/// Detecta los cambios de tasa comparando la activa con la última vista en el
/// dispositivo. La primera tasa que se ve no avisa: solo se recuerda.

@ProviderFor(RateChangeNoticeController)
final rateChangeNoticeControllerProvider = RateChangeNoticeControllerProvider._();

/// Detecta los cambios de tasa comparando la activa con la última vista en el
/// dispositivo. La primera tasa que se ve no avisa: solo se recuerda.
final class RateChangeNoticeControllerProvider
    extends $NotifierProvider<RateChangeNoticeController, RateChangeNotice?> {
  /// Detecta los cambios de tasa comparando la activa con la última vista en el
  /// dispositivo. La primera tasa que se ve no avisa: solo se recuerda.
  RateChangeNoticeControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rateChangeNoticeControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rateChangeNoticeControllerHash();

  @$internal
  @override
  RateChangeNoticeController create() => RateChangeNoticeController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RateChangeNotice? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RateChangeNotice?>(value),
    );
  }
}

String _$rateChangeNoticeControllerHash() => r'81bd43cb14f170c6b655d46759f189a2a26f78ff';

/// Detecta los cambios de tasa comparando la activa con la última vista en el
/// dispositivo. La primera tasa que se ve no avisa: solo se recuerda.

abstract class _$RateChangeNoticeController extends $Notifier<RateChangeNotice?> {
  RateChangeNotice? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<RateChangeNotice?, RateChangeNotice?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<RateChangeNotice?, RateChangeNotice?>,
              RateChangeNotice?,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
