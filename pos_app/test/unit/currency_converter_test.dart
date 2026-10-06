import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/currency/currency_converter.dart';

Decimal d(String value) => Decimal.parse(value);

void main() {
  test('USD a VES redondea a 2 decimales', () {
    expect(CurrencyConverter.usdToVes(d('12.50'), d('872.3927')), d('10904.91'));
    expect(CurrencyConverter.usdToVes(d('10'), d('150')), d('1500.00'));
    expect(CurrencyConverter.usdToVes(d('0.01'), d('150.1235')), d('1.50'));
  });

  test('VES a USD redondea a 2 decimales', () {
    expect(CurrencyConverter.vesToUsd(d('1500'), d('150')), d('10.00'));
    expect(CurrencyConverter.vesToUsd(d('100'), d('3')), d('33.33'));
    expect(CurrencyConverter.vesToUsd(d('1'), d('872.3927')), d('0.00'));
  });

  test('rechaza tasas no positivas', () {
    expect(() => CurrencyConverter.usdToVes(d('1'), Decimal.zero), throwsArgumentError);
    expect(() => CurrencyConverter.vesToUsd(d('1'), d('-150')), throwsArgumentError);
  });
}
