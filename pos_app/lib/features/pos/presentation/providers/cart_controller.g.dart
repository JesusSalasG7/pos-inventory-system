// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Carrito de la venta en curso.
///
/// Vive mientras dure la sesión: no se pierde al pasar del POS al cobro ni al
/// ir a abrir la caja. Se vacía al cambiar de sucursal, porque el stock y la
/// caja son de cada sede.

@ProviderFor(CartController)
final cartControllerProvider = CartControllerProvider._();

/// Carrito de la venta en curso.
///
/// Vive mientras dure la sesión: no se pierde al pasar del POS al cobro ni al
/// ir a abrir la caja. Se vacía al cambiar de sucursal, porque el stock y la
/// caja son de cada sede.
final class CartControllerProvider extends $NotifierProvider<CartController, Cart> {
  /// Carrito de la venta en curso.
  ///
  /// Vive mientras dure la sesión: no se pierde al pasar del POS al cobro ni al
  /// ir a abrir la caja. Se vacía al cambiar de sucursal, porque el stock y la
  /// caja son de cada sede.
  CartControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cartControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cartControllerHash();

  @$internal
  @override
  CartController create() => CartController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Cart value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<Cart>(value));
  }
}

String _$cartControllerHash() => r'97bac23c22d374991a4c3c7db298696109d0b190';

/// Carrito de la venta en curso.
///
/// Vive mientras dure la sesión: no se pierde al pasar del POS al cobro ni al
/// ir a abrir la caja. Se vacía al cambiar de sucursal, porque el stock y la
/// caja son de cada sede.

abstract class _$CartController extends $Notifier<Cart> {
  Cart build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<Cart, Cart>;
    final element =
        ref.element as $ClassProviderElement<AnyNotifier<Cart, Cart>, Cart, Object?, Object?>;
    element.handleCreate(ref, build);
  }
}

/// Marca que hay que volver a Vender en cuanto se abra la caja: el POS manda
/// a abrirla cuando no hay ninguna, sin perder el carrito.

@ProviderFor(ReturnToSell)
final returnToSellProvider = ReturnToSellProvider._();

/// Marca que hay que volver a Vender en cuanto se abra la caja: el POS manda
/// a abrirla cuando no hay ninguna, sin perder el carrito.
final class ReturnToSellProvider extends $NotifierProvider<ReturnToSell, bool> {
  /// Marca que hay que volver a Vender en cuanto se abra la caja: el POS manda
  /// a abrirla cuando no hay ninguna, sin perder el carrito.
  ReturnToSellProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'returnToSellProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$returnToSellHash();

  @$internal
  @override
  ReturnToSell create() => ReturnToSell();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<bool>(value));
  }
}

String _$returnToSellHash() => r'eb8093ec4b454b3ab0ec2394a99ca2fa82a7784c';

/// Marca que hay que volver a Vender en cuanto se abra la caja: el POS manda
/// a abrirla cuando no hay ninguna, sin perder el carrito.

abstract class _$ReturnToSell extends $Notifier<bool> {
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
