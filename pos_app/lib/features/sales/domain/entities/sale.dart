import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';
import 'package:pos_app/core/domain/enums.dart';

/// Venta tal como la registró el backend, con la tasa y los totales congelados.
@immutable
class Sale {
  const Sale({
    required this.id,
    required this.cashSessionId,
    required this.userId,
    required this.branchCode,
    required this.customerTaxId,
    required this.customerName,
    required this.exchangeRateAtInvoice,
    required this.totalUsd,
    required this.totalVes,
    required this.createdAt,
    required this.details,
    required this.payments,
  });

  final int id;
  final int cashSessionId;
  final int userId;
  final String branchCode;
  final String customerTaxId;
  final String customerName;

  /// Tasa con la que se facturó. Las ventas pasadas se muestran SIEMPRE con
  /// esta tasa, nunca con la activa de hoy.
  final Decimal exchangeRateAtInvoice;
  final Decimal totalUsd;
  final Decimal totalVes;
  final DateTime createdAt;
  final List<SaleDetail> details;
  final List<SalePayment> payments;
}

/// Línea de una venta. El backend solo guarda el id del producto, no su nombre.
@immutable
class SaleDetail {
  const SaleDetail({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.unitPriceUsd,
    required this.subtotalUsd,
    required this.subtotalVes,
  });

  final int id;
  final int productId;
  final Decimal quantity;
  final Decimal unitPriceUsd;
  final Decimal subtotalUsd;

  /// Lo facturado en VES por la línea. Con el redondeo del negocio no es el
  /// subtotal en USD por la tasa: se muestra siempre este valor.
  final Decimal subtotalVes;
}

@immutable
class SalePayment {
  const SalePayment({
    required this.id,
    required this.method,
    required this.currency,
    required this.amount,
    required this.approvalReference,
  });

  final int id;
  final PaymentMethod method;
  final Currency currency;
  final Decimal amount;
  final String approvalReference;
}

/// Datos que la app envía para registrar una venta. Nunca incluye precios:
/// salen de la base de datos.
@immutable
class NewSale {
  const NewSale({
    required this.branchCode,
    required this.items,
    required this.payments,
    this.customerTaxId = '',
    this.customerName = '',
  });

  final String branchCode;
  final List<NewSaleItem> items;
  final List<NewSalePayment> payments;
  final String customerTaxId;
  final String customerName;
}

@immutable
class NewSaleItem {
  const NewSaleItem({required this.productId, required this.quantity});

  final int productId;
  final Decimal quantity;
}

@immutable
class NewSalePayment {
  const NewSalePayment({required this.method, required this.amount, this.approvalReference = ''});

  final PaymentMethod method;

  /// Monto en la moneda del método (`method.currency`).
  final Decimal amount;
  final String approvalReference;

  @override
  bool operator ==(Object other) =>
      other is NewSalePayment &&
      other.method == method &&
      other.amount == amount &&
      other.approvalReference == approvalReference;

  @override
  int get hashCode => Object.hash(method, amount, approvalReference);

  @override
  String toString() => 'NewSalePayment(${method.apiValue}, $amount, $approvalReference)';
}
