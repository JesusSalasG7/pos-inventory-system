import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';
import 'package:pos_app/core/domain/enums.dart';
import 'package:pos_app/core/errors/failure.dart';
import 'package:pos_app/core/session/active_branch_provider.dart';
import 'package:pos_app/features/cash_session/presentation/providers/current_session_provider.dart';
import 'package:pos_app/features/exchange_rate/presentation/providers/active_rate_provider.dart';
import 'package:pos_app/features/exchange_rate/presentation/providers/pricing_settings_provider.dart';
import 'package:pos_app/features/home/presentation/providers/dashboard_providers.dart';
import 'package:pos_app/features/inventory/presentation/providers/catalog_providers.dart';
import 'package:pos_app/features/pos/domain/checkout_math.dart';
import 'package:pos_app/features/pos/domain/sale_receipt.dart';
import 'package:pos_app/features/pos/presentation/providers/cart_controller.dart';
import 'package:pos_app/features/sales/data/repositories/sales_repository_impl.dart';
import 'package:pos_app/features/sales/domain/entities/sale.dart';
import 'package:pos_app/features/sales/presentation/providers/sales_history_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'checkout_controller.g.dart';

@immutable
class CheckoutState {
  const CheckoutState({this.lines = const [], this.isSubmitting = false});

  final List<PaymentLine> lines;

  /// `true` mientras se envía la venta: bloquea el doble envío.
  final bool isSubmitting;

  CheckoutState copyWith({List<PaymentLine>? lines, bool? isSubmitting}) =>
      CheckoutState(lines: lines ?? this.lines, isSubmitting: isSubmitting ?? this.isSubmitting);
}

/// Líneas de pago del cobro y envío de la venta.
@riverpod
class CheckoutController extends _$CheckoutController {
  int _nextId = 1;

  @override
  CheckoutState build() => const CheckoutState();

  /// Cuadre de los pagos con el total del carrito y la tasa activa; `null`
  /// si todavía no hay tasa.
  CheckoutSummary? summary() {
    final rate = ref.read(activeRateProvider).value;
    if (rate == null) return null;
    final cart = ref.read(cartControllerProvider);
    return CheckoutMath.compute(
      totalUsd: cart.totalUsd,
      totalVes: cart.totalVes(rate, roundUp: ref.read(roundVesUpProvider)),
      rate: rate,
      lines: state.lines,
    );
  }

  /// Agrega una línea del método indicado, prellenada con lo que falta por cobrar.
  void addLine(PaymentMethod method) {
    final rate = ref.read(activeRateProvider).value;
    final cart = ref.read(cartControllerProvider);
    final prefill = rate == null
        ? null
        : CheckoutMath.prefillFor(
            method: method,
            totalUsd: cart.totalUsd,
            totalVes: cart.totalVes(rate, roundUp: ref.read(roundVesUpProvider)),
            rate: rate,
            lines: state.lines,
          );
    state = state.copyWith(
      lines: [
        ...state.lines,
        PaymentLine(id: _nextId++, method: method, amount: prefill),
      ],
    );
  }

  void updateAmount(int lineId, Decimal? amount) {
    _update(lineId, (line) => line.copyWith(amount: () => amount));
  }

  void updateReference(int lineId, String reference) {
    _update(lineId, (line) => line.copyWith(reference: reference));
  }

  void removeLine(int lineId) {
    state = state.copyWith(
      lines: [
        for (final line in state.lines)
          if (line.id != lineId) line,
      ],
    );
  }

  /// Registra la venta. Devuelve el comprobante con los datos del backend.
  ///
  /// Lanza `Failure` si el backend la rechaza. Antes de relanzar deja el
  /// carrito coherente: marca el stock disponible ante `insufficient_stock` y
  /// quita los productos de `inactive_product`.
  Future<SaleReceipt> submit() async {
    final cart = ref.read(cartControllerProvider);
    final branch = ref.read(activeBranchProvider);
    final checkout = summary();
    if (state.isSubmitting || branch == null || checkout == null || !checkout.canConfirm) {
      throw StateError('La venta no está lista para enviarse.');
    }

    state = state.copyWith(isSubmitting: true);
    try {
      final sale = await ref
          .read(salesRepositoryProvider)
          .createSale(
            NewSale(
              branchCode: branch.code,
              customerTaxId: cart.customerTaxId,
              customerName: cart.customerName,
              items: [
                for (final item in cart.items)
                  NewSaleItem(productId: item.product.id, quantity: item.quantity),
              ],
              payments: checkout.payments,
            ),
          );
      final receipt = SaleReceipt(
        sale: sale,
        branchName: branch.name,
        productNames: {for (final item in cart.items) item.product.id: item.product.name},
      );
      ref.read(cartControllerProvider.notifier).clear();
      // La venta movió stock, caja y totales del día.
      ref
        ..invalidate(sellableCatalogProvider)
        ..invalidate(todaySalesSummaryProvider)
        ..invalidate(salesHistoryProvider)
        ..invalidate(daySalesSummaryProvider)
        ..invalidate(lowStockCountProvider)
        ..invalidate(sessionSummaryProvider(sale.cashSessionId))
        ..invalidate(sessionSalesReportProvider(sale.cashSessionId));
      state = const CheckoutState();
      return receipt;
    } on Failure catch (failure) {
      _reconcileCart(failure);
      state = state.copyWith(isSubmitting: false);
      rethrow;
    }
  }

  void _reconcileCart(Failure failure) {
    final cartController = ref.read(cartControllerProvider.notifier);
    switch (failure.code) {
      case 'insufficient_stock':
        final items = failure.meta['items'];
        if (items is! List) return;
        cartController.applyAvailableStock({
          for (final item in items.whereType<Map<dynamic, dynamic>>())
            if (item['product_id'] is int && item['available'] != null)
              item['product_id'] as int:
                  Decimal.tryParse(item['available'].toString()) ?? Decimal.zero,
        });
        ref.invalidate(sellableCatalogProvider);
      case 'inactive_product':
        final ids = failure.meta['product_ids'];
        if (ids is! List) return;
        cartController.removeProducts(ids.whereType<int>().toSet());
        ref.invalidate(sellableCatalogProvider);
      case 'no_open_session':
        ref.invalidate(currentSessionProvider);
    }
  }

  void _update(int lineId, PaymentLine Function(PaymentLine line) change) {
    state = state.copyWith(
      lines: [for (final line in state.lines) line.id == lineId ? change(line) : line],
    );
  }
}
