// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pricing_settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Configuración de precios del negocio: modo de tasa y redondeo en bolívares.
/// La cambia un MANAGER; la app la relee al iniciar sesión y al refrescar la tasa.

@ProviderFor(PricingSettingsController)
final pricingSettingsControllerProvider = PricingSettingsControllerProvider._();

/// Configuración de precios del negocio: modo de tasa y redondeo en bolívares.
/// La cambia un MANAGER; la app la relee al iniciar sesión y al refrescar la tasa.
final class PricingSettingsControllerProvider
    extends $AsyncNotifierProvider<PricingSettingsController, PricingSettings> {
  /// Configuración de precios del negocio: modo de tasa y redondeo en bolívares.
  /// La cambia un MANAGER; la app la relee al iniciar sesión y al refrescar la tasa.
  PricingSettingsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pricingSettingsControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pricingSettingsControllerHash();

  @$internal
  @override
  PricingSettingsController create() => PricingSettingsController();
}

String _$pricingSettingsControllerHash() => r'72afd7027190af2d9779ca485b3c252427229393';

/// Configuración de precios del negocio: modo de tasa y redondeo en bolívares.
/// La cambia un MANAGER; la app la relee al iniciar sesión y al refrescar la tasa.

abstract class _$PricingSettingsController extends $AsyncNotifier<PricingSettings> {
  FutureOr<PricingSettings> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<PricingSettings>, PricingSettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<PricingSettings>, PricingSettings>,
              AsyncValue<PricingSettings>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// `true` si los precios en bolívares se redondean hacia arriba. Mientras la
/// configuración carga, o si falla, se asume que no.

@ProviderFor(roundVesUp)
final roundVesUpProvider = RoundVesUpProvider._();

/// `true` si los precios en bolívares se redondean hacia arriba. Mientras la
/// configuración carga, o si falla, se asume que no.

final class RoundVesUpProvider extends $FunctionalProvider<bool, bool, bool> with $Provider<bool> {
  /// `true` si los precios en bolívares se redondean hacia arriba. Mientras la
  /// configuración carga, o si falla, se asume que no.
  RoundVesUpProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'roundVesUpProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$roundVesUpHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return roundVesUp(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<bool>(value));
  }
}

String _$roundVesUpHash() => r'c4c4c6b46fc1dba2262079b16d3d8fb418aec861';
