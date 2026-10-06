import 'package:decimal/decimal.dart';
import 'package:pos_app/core/currency/money.dart';
import 'package:pos_app/core/session/active_branch_provider.dart';
import 'package:pos_app/features/inventory/domain/entities/product.dart';
import 'package:pos_app/features/pos/domain/cart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cart_controller.g.dart';

/// Carrito de la venta en curso.
///
/// Vive mientras dure la sesión: no se pierde al pasar del POS al cobro ni al
/// ir a abrir la caja. Se vacía al cambiar de sucursal, porque el stock y la
/// caja son de cada sede.
@Riverpod(keepAlive: true)
class CartController extends _$CartController {
  @override
  Cart build() {
    ref.listen(activeBranchProvider, (previous, next) {
      if (previous?.code != next?.code) state = const Cart();
    });
    return const Cart();
  }

  /// Fija la cantidad de un producto del catálogo. Se limita al stock
  /// disponible; con cero se quita del carrito.
  void setQuantity(StockedProduct stocked, Decimal quantity) {
    _set(
      product: stocked.product,
      quantity: quantity,
      availableStock: stocked.currentStock,
      minimumStock: stocked.minimumStock,
    );
  }

  /// Cambia la cantidad de una línea que ya está en el carrito (desde el cobro).
  void setItemQuantity(int productId, Decimal quantity) {
    for (final item in state.items) {
      if (item.product.id == productId) {
        _set(
          product: item.product,
          quantity: quantity,
          availableStock: item.availableStock,
          minimumStock: item.minimumStock,
        );
        return;
      }
    }
  }

  void remove(int productId) => removeProducts({productId});

  /// Quita varias líneas, p. ej. las de productos que el backend rechazó por inactivos.
  void removeProducts(Set<int> productIds) {
    state = state.copyWith(
      items: [
        for (final item in state.items)
          if (!productIds.contains(item.product.id)) item,
      ],
    );
  }

  /// Actualiza el stock disponible de las líneas con lo que informó el backend
  /// al rechazar la venta por `insufficient_stock`. No cambia las cantidades:
  /// el cajero decide cómo ajustarlas.
  void applyAvailableStock(Map<int, Decimal> availableByProduct) {
    state = state.copyWith(
      items: [
        for (final item in state.items)
          availableByProduct.containsKey(item.product.id)
              ? item.copyWith(availableStock: availableByProduct[item.product.id])
              : item,
      ],
    );
  }

  void setCustomer({String? taxId, String? name}) {
    state = state.copyWith(customerTaxId: taxId, customerName: name);
  }

  void clear() => state = const Cart();

  void _set({
    required Product product,
    required Decimal quantity,
    required Decimal availableStock,
    required Decimal minimumStock,
  }) {
    var clamped = quantizeQuantity(quantity);
    if (clamped > availableStock) clamped = availableStock;
    if (clamped <= Decimal.zero) {
      remove(product.id);
      return;
    }
    final item = CartItem(
      product: product,
      quantity: clamped,
      availableStock: availableStock,
      minimumStock: minimumStock,
    );
    final exists = state.items.any((existing) => existing.product.id == product.id);
    state = state.copyWith(
      items: exists
          ? [
              for (final existing in state.items)
                existing.product.id == product.id ? item : existing,
            ]
          : [...state.items, item],
    );
  }
}

/// Marca que hay que volver a Vender en cuanto se abra la caja: el POS manda
/// a abrirla cuando no hay ninguna, sin perder el carrito.
@Riverpod(keepAlive: true)
class ReturnToSell extends _$ReturnToSell {
  @override
  bool build() => false;

  void request() => state = true;

  /// Devuelve si había una vuelta pendiente y la da por atendida.
  bool consume() {
    final pending = state;
    state = false;
    return pending;
  }
}
