import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/currency/money.dart';

Decimal d(String value) => Decimal.parse(value);

void main() {
  group('redondeo (mitad hacia arriba, como el backend)', () {
    test('dinero a 2 decimales', () {
      expect(quantizeMoney(d('1.005')), d('1.01'));
      expect(quantizeMoney(d('1.004')), d('1.00'));
      expect(quantizeMoney(d('2.675')), d('2.68'));
      expect(quantizeMoney(d('-1.005')), d('-1.01'));
    });

    test('cantidades a 3 decimales y tasas a 4', () {
      expect(quantizeQuantity(d('2.0005')), d('2.001'));
      expect(quantizeQuantity(d('2.0004')), d('2.000'));
      expect(quantizeRate(d('150.123456')), d('150.1235'));
    });
  });

  group('formato de la API', () {
    test('siempre string decimal con escala fija', () {
      expect(moneyToApi(d('12.5')), '12.50');
      expect(moneyToApi(d('0.1') + d('0.2')), '0.30');
      expect(quantityToApi(d('2.5')), '2.500');
      expect(rateToApi(d('872.3927')), '872.3927');
      expect(rateToApi(d('150')), '150.0000');
    });

    test('parsea los strings del backend sin perder precisión', () {
      expect(parseDecimal(' 10904.88 '), d('10904.88'));
      expect(parseDecimal('0.10') + parseDecimal('0.20'), d('0.3'));
      expect(() => parseDecimal('abc'), throwsFormatException);
    });
  });

  group('texto escrito por el usuario', () {
    test('acepta coma o punto', () {
      expect(tryParseUserDecimal('2,5'), d('2.5'));
      expect(tryParseUserDecimal('2.5'), d('2.5'));
      expect(tryParseUserDecimal(' 12 '), d('12'));
    });

    test('vacío o inválido es null', () {
      expect(tryParseUserDecimal(null), isNull);
      expect(tryParseUserDecimal(''), isNull);
      expect(tryParseUserDecimal(','), isNull);
      expect(tryParseUserDecimal('1,2,3'), isNull);
    });
  });

  test('divide con precisión suficiente y rechaza el cero', () {
    expect(quantizeMoney(divide(d('100'), d('3'))), d('33.33'));
    expect(quantizeMoney(divide(d('200'), d('3'))), d('66.67'));
    expect(() => divide(d('1'), Decimal.zero), throwsArgumentError);
  });

  test('la tolerancia de cuadre es 0,01 USD', () {
    expect(paymentToleranceUsd, d('0.01'));
  });
}
