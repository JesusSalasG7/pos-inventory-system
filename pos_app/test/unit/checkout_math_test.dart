import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/domain/enums.dart';
import 'package:pos_app/features/pos/domain/checkout_math.dart';
import 'package:pos_app/features/sales/domain/entities/sale.dart';

import '../mocks/fake_repositories.dart';

var _id = 0;
PaymentLine line(PaymentMethod method, String? amount, {String reference = ''}) => PaymentLine(
  id: ++_id,
  method: method,
  amount: amount == null ? null : dec(amount),
  reference: reference,
);

CheckoutSummary compute(String total, List<PaymentLine> lines, {String rate = '150'}) =>
    CheckoutMath.compute(totalUsd: dec(total), rate: dec(rate), lines: lines);

void main() {
  group('estado del cobro', () {
    test('sin pagos no se puede confirmar', () {
      final summary = compute('10', []);

      expect(summary.status, CheckoutStatus.noPayments);
      expect(summary.canConfirm, isFalse);
    });

    test('pago exacto en dólares', () {
      final summary = compute('10', [line(PaymentMethod.cashUsd, '10')]);

      expect(summary.status, CheckoutStatus.exact);
      expect(summary.canConfirm, isTrue);
      expect(summary.payments, [
        NewSalePayment(method: PaymentMethod.cashUsd, amount: dec('10.00')),
      ]);
    });

    test('falta dinero: restante en las dos monedas', () {
      final summary = compute('10', [line(PaymentMethod.cashUsd, '4')]);

      expect(summary.status, CheckoutStatus.remaining);
      expect(summary.remainingUsd, dec('6.00'));
      expect(summary.remainingVes, dec('900.00'));
      expect(summary.canConfirm, isFalse);
    });

    test('pago mixto: los bolívares se convierten una sola vez, como en el backend', () {
      // 100 Bs / 3 = 33,33 $; dos pagos de 50 Bs no deben dar 16,67 + 16,67 = 33,34.
      final summary = compute('33.33', [
        line(PaymentMethod.cashVes, '50'),
        line(PaymentMethod.mobilePayment, '50', reference: 'A1'),
      ], rate: '3');

      expect(summary.paidUsd, dec('33.33'));
      expect(summary.status, CheckoutStatus.exact);
    });

    test('cuadra dentro de la tolerancia de 0,01 USD y no más', () {
      expect(compute('10.01', [line(PaymentMethod.cashUsd, '10')]).status, CheckoutStatus.exact);
      expect(
        compute('10.02', [line(PaymentMethod.cashUsd, '10')]).status,
        CheckoutStatus.remaining,
      );
    });
  });

  group('referencia obligatoria', () {
    test('pago móvil y punto de venta exigen referencia', () {
      for (final method in [PaymentMethod.mobilePayment, PaymentMethod.posCard]) {
        final missing = compute('10', [line(method, '1500')]);
        expect(missing.status, CheckoutStatus.incomplete, reason: method.apiValue);
        expect(missing.canConfirm, isFalse);

        final complete = compute('10', [line(method, '1500', reference: ' 004512 ')]);
        expect(complete.status, CheckoutStatus.exact, reason: method.apiValue);
        expect(complete.payments.single.approvalReference, '004512');
      }
    });

    test('el efectivo no la necesita', () {
      expect(compute('10', [line(PaymentMethod.cashVes, '1500')]).status, CheckoutStatus.exact);
    });

    test('una línea sin monto deja el cobro incompleto', () {
      final summary = compute('10', [
        line(PaymentMethod.cashUsd, '10'),
        line(PaymentMethod.cashVes, null),
      ]);

      expect(summary.status, CheckoutStatus.incomplete);
    });
  });

  group('vuelto (solo visual: a la API va el monto exacto)', () {
    test('en dólares: se descuenta del efectivo en dólares', () {
      final summary = compute('7.50', [line(PaymentMethod.cashUsd, '10')]);

      expect(summary.status, CheckoutStatus.change);
      expect(summary.changeCurrency, Currency.usd);
      expect(summary.changeAmount, dec('2.50'));
      expect(summary.payments.single.amount, dec('7.50'));
      expect(summary.canConfirm, isTrue);
    });

    test('en bolívares: se descuenta del efectivo en bolívares', () {
      final summary = compute('10', [line(PaymentMethod.cashVes, '2000')]);

      expect(summary.status, CheckoutStatus.change);
      expect(summary.changeCurrency, Currency.ves);
      expect(summary.changeAmount, dec('500.00'));
      expect(summary.payments.single.amount, dec('1500.00'));
    });

    test('pago mixto: el vuelto sale del último pago en efectivo', () {
      final summary = compute('10', [
        line(PaymentMethod.cashUsd, '5'),
        line(PaymentMethod.mobilePayment, '300', reference: 'R1'),
        line(PaymentMethod.cashVes, '1000'),
      ]);

      // Faltaban 5 $ − 2 $ del pago móvil = 3 $ = 450 Bs; entregó 1.000 Bs.
      expect(summary.status, CheckoutStatus.change);
      expect(summary.changeCurrency, Currency.ves);
      expect(summary.changeAmount, dec('550.00'));
      expect(summary.payments.map((p) => p.amount), [dec('5.00'), dec('300.00'), dec('450.00')]);
    });

    test('lo enviado cuadra con el total tras descontar el vuelto', () {
      final summary = compute('12.37', [
        line(PaymentMethod.cashUsd, '5'),
        line(PaymentMethod.cashVes, '9000'),
      ], rate: '872.3927');

      expect(summary.status, CheckoutStatus.change);
      final usd = summary.payments.first.amount;
      final ves = summary.payments.last.amount;
      final paid = CheckoutMath.paidUsd(usd: usd, ves: ves, rate: dec('872.3927'));
      expect((paid - dec('12.37')).abs() <= dec('0.01'), isTrue);
    });

    test('sin efectivo no hay de dónde dar vuelto', () {
      final summary = compute('10', [line(PaymentMethod.posCard, '2000', reference: 'R1')]);

      expect(summary.status, CheckoutStatus.overpaidWithoutCash);
      expect(summary.canConfirm, isFalse);
    });

    test('si el vuelto supera el efectivo, esa línea sobra', () {
      final summary = compute('10', [
        line(PaymentMethod.posCard, '1500', reference: 'R1'),
        line(PaymentMethod.cashUsd, '5'),
      ]);

      expect(summary.status, CheckoutStatus.changeExceedsCash);
      expect(summary.canConfirm, isFalse);
    });
  });

  group('prellenado de una línea nueva', () {
    Decimal? prefill(PaymentMethod method, String total, List<PaymentLine> lines) =>
        CheckoutMath.prefillFor(
          method: method,
          totalUsd: dec(total),
          rate: dec('150'),
          lines: lines,
        );

    test('con el restante en la moneda del método', () {
      expect(prefill(PaymentMethod.cashUsd, '10', []), dec('10.00'));
      expect(prefill(PaymentMethod.cashVes, '10', []), dec('1500.00'));
      expect(
        prefill(PaymentMethod.mobilePayment, '10', [line(PaymentMethod.cashUsd, '4')]),
        dec('900.00'),
      );
      expect(
        prefill(PaymentMethod.cashUsd, '10', [line(PaymentMethod.cashVes, '600')]),
        dec('6.00'),
      );
    });

    test('vacío si ya no falta nada', () {
      expect(prefill(PaymentMethod.cashUsd, '10', [line(PaymentMethod.cashUsd, '10')]), isNull);
      expect(prefill(PaymentMethod.cashVes, '10', [line(PaymentMethod.cashUsd, '12')]), isNull);
    });

    test('prellenar y confirmar siempre cuadra', () {
      final lines = [line(PaymentMethod.cashUsd, '3.33')];
      final rest = CheckoutMath.prefillFor(
        method: PaymentMethod.posCard,
        totalUsd: dec('19.99'),
        rate: dec('872.3927'),
        lines: lines,
      )!;
      final summary = CheckoutMath.compute(
        totalUsd: dec('19.99'),
        rate: dec('872.3927'),
        lines: [
          ...lines,
          PaymentLine(id: 99, method: PaymentMethod.posCard, amount: rest, reference: 'R'),
        ],
      );

      expect(summary.status, CheckoutStatus.exact);
    });
  });
}
