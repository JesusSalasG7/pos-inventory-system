// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Productos activos con su stock en la sucursal activa, para vender.
///
/// `inventory/` no filtra ni trae precio o categoría, así que se piden el
/// catálogo y el inventario completos en paralelo y se cruzan aquí. Un
/// producto sin fila de inventario en la sucursal cuenta como stock cero.

@ProviderFor(sellableCatalog)
final sellableCatalogProvider = SellableCatalogProvider._();

/// Productos activos con su stock en la sucursal activa, para vender.
///
/// `inventory/` no filtra ni trae precio o categoría, así que se piden el
/// catálogo y el inventario completos en paralelo y se cruzan aquí. Un
/// producto sin fila de inventario en la sucursal cuenta como stock cero.

final class SellableCatalogProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<StockedProduct>>,
          List<StockedProduct>,
          FutureOr<List<StockedProduct>>
        >
    with $FutureModifier<List<StockedProduct>>, $FutureProvider<List<StockedProduct>> {
  /// Productos activos con su stock en la sucursal activa, para vender.
  ///
  /// `inventory/` no filtra ni trae precio o categoría, así que se piden el
  /// catálogo y el inventario completos en paralelo y se cruzan aquí. Un
  /// producto sin fila de inventario en la sucursal cuenta como stock cero.
  SellableCatalogProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sellableCatalogProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sellableCatalogHash();

  @$internal
  @override
  $FutureProviderElement<List<StockedProduct>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<List<StockedProduct>> create(Ref ref) {
    return sellableCatalog(ref);
  }
}

String _$sellableCatalogHash() => r'c8817cc9b04a4a4d8ff394172d5adb826cda241f';
