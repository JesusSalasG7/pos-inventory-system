import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';
import 'package:pos_app/core/currency/currency_converter.dart';
import 'package:pos_app/core/currency/money.dart';
import 'package:pos_app/core/domain/enums.dart';
import 'package:pos_app/features/sales/domain/entities/sale.dart';

/// Línea de pago que el cajero está armando en el cobro.
@immutable
class PaymentLine {
  const PaymentLine({required this.id, required this.method, this.amount, this.reference = ''});

  /// Identificador local, estable mientras la línea exista.
  final int id;
  final PaymentMethod method;

  /// Monto en la moneda del método; `null` mientras el campo está vacío.
  final Decimal? amount;
  final String reference;

  bool get hasAmount => (amount ?? Decimal.zero) > Decimal.zero;
  bool get isMissingReference => method.requiresReference && reference.trim().isEmpty;
  bool get isValid => hasAmount && !isMissingReference;

  PaymentLine copyWith({Decimal? Function()? amount, String? reference}) => PaymentLine(
    id: id,
    method: method,
    amount: amount == null ? this.amount : amount(),
    reference: reference ?? this.reference,
  );
}

enum CheckoutStatus {
  /// Todavía no hay ninguna línea de pago.
  noPayments,

  /// Alguna línea no tiene monto o le falta la referencia obligatoria.
  incomplete,

  /// Falta dinero por cobrar.
  remaining,

  /// Los pagos cuadran con el total (dentro de 0,01 USD).
  exact,

  /// Sobra dinero y se devuelve como vuelto del último pago en efectivo.
  change,

  /// Sobra dinero pero no hay pago en efectivo del que dar vuelto.
  overpaidWithoutCash,

  /// El vuelto sería mayor que el último pago en efectivo: esa línea sobra.
  changeExceedsCash,
}

/// Resultado de cuadrar los pagos contra el total de la venta.
@immutable
class CheckoutSummary {
  const CheckoutSummary({
    required this.status,
    required this.totalUsd,
    required this.paidUsd,
    this.remainingUsd,
    this.remainingVes,
    this.changeAmount,
    this.changeCurrency,
    this.payments = const [],
  });

  final CheckoutStatus status;
  final Decimal totalUsd;

  /// Lo pagado, en USD, con la misma conversión que hace el backend.
  final Decimal paidUsd;

  /// Lo que falta, en cada moneda. Solo con `status == remaining`.
  final Decimal? remainingUsd;
  final Decimal? remainingVes;

  /// Vuelto, en `changeCurrency` (la moneda del último pago en efectivo).
  final Decimal? changeAmount;
  final Currency? changeCurrency;

  /// Pagos tal como se enviarán a la API: el vuelto ya está descontado del
  /// último pago en efectivo, porque el backend no modela el vuelto.
  final List<NewSalePayment> payments;

  bool get canConfirm => status == CheckoutStatus.exact || status == CheckoutStatus.change;
}

/// Cuadre de pagos mixtos. Replica `sale_calculator.payments_total_usd` del
/// backend: los bolívares se suman entre sí y se convierten a USD una sola vez.
abstract final class CheckoutMath {
  /// Lo pagado en USD: dólares más bolívares convertidos una sola vez.
  static Decimal paidUsd({required Decimal usd, required Decimal ves, required Decimal rate}) =>
      quantizeMoney(usd + CurrencyConverter.vesToUsd(ves, rate));

  static CheckoutSummary compute({
    required Decimal totalUsd,
    required Decimal rate,
    required List<PaymentLine> lines,
  }) {
    final total = quantizeMoney(totalUsd);
    final usd = _sum(lines, Currency.usd);
    final ves = _sum(lines, Currency.ves);
    final paid = paidUsd(usd: usd, ves: ves, rate: rate);

    CheckoutSummary result(
      CheckoutStatus status, {
      Decimal? remainingUsd,
      Decimal? remainingVes,
      Decimal? changeAmount,
      Currency? changeCurrency,
      List<NewSalePayment> payments = const [],
    }) => CheckoutSummary(
      status: status,
      totalUsd: total,
      paidUsd: paid,
      remainingUsd: remainingUsd,
      remainingVes: remainingVes,
      changeAmount: changeAmount,
      changeCurrency: changeCurrency,
      payments: payments,
    );

    if (lines.isEmpty) return result(CheckoutStatus.noPayments);

    final difference = paid - total;
    if (difference < -paymentToleranceUsd) {
      final remaining = total - paid;
      return result(
        CheckoutStatus.remaining,
        remainingUsd: remaining,
        remainingVes: CurrencyConverter.usdToVes(remaining, rate),
      );
    }
    if (lines.any((line) => !line.isValid)) return result(CheckoutStatus.incomplete);
    if (difference <= paymentToleranceUsd) {
      return result(CheckoutStatus.exact, payments: _toPayments(lines));
    }

    // Sobra dinero: el vuelto sale del último pago en efectivo.
    final cashIndex = lines.lastIndexWhere((line) => line.method.isCash);
    if (cashIndex < 0) return result(CheckoutStatus.overpaidWithoutCash);
    final cashLine = lines[cashIndex];

    final Decimal adjusted;
    if (cashLine.method.currency == Currency.usd) {
      adjusted = cashLine.amount! - difference;
    } else {
      // Bolívares que hacen falta en total para cubrir lo que no pagan los dólares.
      final neededVes = CurrencyConverter.usdToVes(total - usd, rate);
      adjusted = neededVes - (ves - cashLine.amount!);
    }
    if (adjusted <= Decimal.zero) return result(CheckoutStatus.changeExceedsCash);

    final adjustedLines = [...lines]..[cashIndex] = cashLine.copyWith(amount: () => adjusted);
    final adjustedPaid = paidUsd(
      usd: _sum(adjustedLines, Currency.usd),
      ves: _sum(adjustedLines, Currency.ves),
      rate: rate,
    );
    if ((adjustedPaid - total).abs() > paymentToleranceUsd) {
      return result(CheckoutStatus.incomplete);
    }
    return result(
      CheckoutStatus.change,
      changeAmount: cashLine.amount! - adjusted,
      changeCurrency: cashLine.method.currency,
      payments: _toPayments(adjustedLines),
    );
  }

  /// Monto con el que se prellena una línea nueva: lo que falta, en la moneda
  /// del método. `null` si ya no falta nada.
  static Decimal? prefillFor({
    required PaymentMethod method,
    required Decimal totalUsd,
    required Decimal rate,
    required List<PaymentLine> lines,
  }) {
    final total = quantizeMoney(totalUsd);
    final usd = _sum(lines, Currency.usd);
    final ves = _sum(lines, Currency.ves);
    final remainingUsd = total - paidUsd(usd: usd, ves: ves, rate: rate);
    if (remainingUsd <= Decimal.zero) return null;
    if (method.currency == Currency.usd) return remainingUsd;
    // En bolívares se calcula sobre el total, no sobre el restante ya
    // redondeado, para que la suma convertida dé exactamente el total.
    final missingVes = CurrencyConverter.usdToVes(total - usd, rate) - ves;
    return missingVes > Decimal.zero ? missingVes : null;
  }

  static Decimal _sum(List<PaymentLine> lines, Currency currency) => lines
      .where((line) => line.method.currency == currency)
      .fold(Decimal.zero, (sum, line) => sum + (line.amount ?? Decimal.zero));

  static List<NewSalePayment> _toPayments(List<PaymentLine> lines) => [
    for (final line in lines)
      NewSalePayment(
        method: line.method,
        amount: quantizeMoney(line.amount!),
        approvalReference: line.reference.trim(),
      ),
  ];
}
