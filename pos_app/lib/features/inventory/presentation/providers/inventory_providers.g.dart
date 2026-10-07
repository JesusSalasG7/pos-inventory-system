// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inventory_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Todas las categorías del catálogo, también las inactivas, por nombre.
/// Concentra las operaciones de un MANAGER sobre ellas.

@ProviderFor(Categories)
final categoriesProvider = CategoriesProvider._();

/// Todas las categorías del catálogo, también las inactivas, por nombre.
/// Concentra las operaciones de un MANAGER sobre ellas.
final class CategoriesProvider extends $AsyncNotifierProvider<Categories, List<ProductCategory>> {
  /// Todas las categorías del catálogo, también las inactivas, por nombre.
  /// Concentra las operaciones de un MANAGER sobre ellas.
  CategoriesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'categoriesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$categoriesHash();

  @$internal
  @override
  Categories create() => Categories();
}

String _$categoriesHash() => r'9b4ea2212922e3a4b18c49cfd61c9263eb6e521f';

/// Todas las categorías del catálogo, también las inactivas, por nombre.
/// Concentra las operaciones de un MANAGER sobre ellas.

abstract class _$Categories extends $AsyncNotifier<List<ProductCategory>> {
  FutureOr<List<ProductCategory>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<ProductCategory>>, List<ProductCategory>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<ProductCategory>>, List<ProductCategory>>,
              AsyncValue<List<ProductCategory>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Catálogo completo (también los productos inactivos) con su stock en la
/// sucursal activa. Es la fuente de la pestaña Inventario y concentra las
/// operaciones que lo modifican.

@ProviderFor(InventoryCatalog)
final inventoryCatalogProvider = InventoryCatalogProvider._();

/// Catálogo completo (también los productos inactivos) con su stock en la
/// sucursal activa. Es la fuente de la pestaña Inventario y concentra las
/// operaciones que lo modifican.
final class InventoryCatalogProvider
    extends $AsyncNotifierProvider<InventoryCatalog, List<StockedProduct>> {
  /// Catálogo completo (también los productos inactivos) con su stock en la
  /// sucursal activa. Es la fuente de la pestaña Inventario y concentra las
  /// operaciones que lo modifican.
  InventoryCatalogProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'inventoryCatalogProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$inventoryCatalogHash();

  @$internal
  @override
  InventoryCatalog create() => InventoryCatalog();
}

String _$inventoryCatalogHash() => r'54277017cd83335442414a0fea9d150d276f0a8d';

/// Catálogo completo (también los productos inactivos) con su stock en la
/// sucursal activa. Es la fuente de la pestaña Inventario y concentra las
/// operaciones que lo modifican.

abstract class _$InventoryCatalog extends $AsyncNotifier<List<StockedProduct>> {
  FutureOr<List<StockedProduct>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<StockedProduct>>, List<StockedProduct>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<StockedProduct>>, List<StockedProduct>>,
              AsyncValue<List<StockedProduct>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Kardex de la sucursal activa, cargado página a página. Se puede acotar a
/// un producto y a un tipo de movimiento.

@ProviderFor(MovementHistory)
final movementHistoryProvider = MovementHistoryFamily._();

/// Kardex de la sucursal activa, cargado página a página. Se puede acotar a
/// un producto y a un tipo de movimiento.
final class MovementHistoryProvider
    extends $AsyncNotifierProvider<MovementHistory, PagedList<InventoryMovement>> {
  /// Kardex de la sucursal activa, cargado página a página. Se puede acotar a
  /// un producto y a un tipo de movimiento.
  MovementHistoryProvider._({
    required MovementHistoryFamily super.from,
    required ({int? productId, MovementType? type}) super.argument,
  }) : super(
         retry: null,
         name: r'movementHistoryProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$movementHistoryHash();

  @override
  String toString() {
    return r'movementHistoryProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  MovementHistory create() => MovementHistory();

  @override
  bool operator ==(Object other) {
    return other is MovementHistoryProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$movementHistoryHash() => r'd4e7a3400645402efe02cbc21f8938102321d0cf';

/// Kardex de la sucursal activa, cargado página a página. Se puede acotar a
/// un producto y a un tipo de movimiento.

final class MovementHistoryFamily extends $Family
    with
        $ClassFamilyOverride<
          MovementHistory,
          AsyncValue<PagedList<InventoryMovement>>,
          PagedList<InventoryMovement>,
          FutureOr<PagedList<InventoryMovement>>,
          ({int? productId, MovementType? type})
        > {
  MovementHistoryFamily._()
    : super(
        retry: null,
        name: r'movementHistoryProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Kardex de la sucursal activa, cargado página a página. Se puede acotar a
  /// un producto y a un tipo de movimiento.

  MovementHistoryProvider call({int? productId, MovementType? type}) =>
      MovementHistoryProvider._(argument: (productId: productId, type: type), from: this);

  @override
  String toString() => r'movementHistoryProvider';
}

/// Kardex de la sucursal activa, cargado página a página. Se puede acotar a
/// un producto y a un tipo de movimiento.

abstract class _$MovementHistory extends $AsyncNotifier<PagedList<InventoryMovement>> {
  late final _$args = ref.$arg as ({int? productId, MovementType? type});
  int? get productId => _$args.productId;
  MovementType? get type => _$args.type;

  FutureOr<PagedList<InventoryMovement>> build({int? productId, MovementType? type});
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<PagedList<InventoryMovement>>, PagedList<InventoryMovement>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<PagedList<InventoryMovement>>, PagedList<InventoryMovement>>,
              AsyncValue<PagedList<InventoryMovement>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(productId: _$args.productId, type: _$args.type));
  }
}

/// Stock de cada producto en las demás tiendas activas, por código de tienda.
///
/// El backend no tiene un endpoint para comparar tiendas: se pide el
/// inventario de cada una en paralelo. Solo sirve a quien tiene acceso a
/// todas (un MANAGER sin tienda asignada); al resto el backend se lo niega.

@ProviderFor(otherBranchesStock)
final otherBranchesStockProvider = OtherBranchesStockProvider._();

/// Stock de cada producto en las demás tiendas activas, por código de tienda.
///
/// El backend no tiene un endpoint para comparar tiendas: se pide el
/// inventario de cada una en paralelo. Solo sirve a quien tiene acceso a
/// todas (un MANAGER sin tienda asignada); al resto el backend se lo niega.

final class OtherBranchesStockProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<Branch, Map<int, Decimal>>>,
          Map<Branch, Map<int, Decimal>>,
          FutureOr<Map<Branch, Map<int, Decimal>>>
        >
    with
        $FutureModifier<Map<Branch, Map<int, Decimal>>>,
        $FutureProvider<Map<Branch, Map<int, Decimal>>> {
  /// Stock de cada producto en las demás tiendas activas, por código de tienda.
  ///
  /// El backend no tiene un endpoint para comparar tiendas: se pide el
  /// inventario de cada una en paralelo. Solo sirve a quien tiene acceso a
  /// todas (un MANAGER sin tienda asignada); al resto el backend se lo niega.
  OtherBranchesStockProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'otherBranchesStockProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$otherBranchesStockHash();

  @$internal
  @override
  $FutureProviderElement<Map<Branch, Map<int, Decimal>>> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Map<Branch, Map<int, Decimal>>> create(Ref ref) {
    return otherBranchesStock(ref);
  }
}

String _$otherBranchesStockHash() => r'82a9fe33bf98cdb3eb1b105ea025102343d15e5c';
