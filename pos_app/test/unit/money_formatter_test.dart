import 'package:decimal/decimal.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/currency/money_formatter.dart';

Decimal d(String value) => Decimal.parse(value);

void main() {
  test('USD con coma decimal y punto de miles', () {
    expect(MoneyFormatter.usd(d('12.5')), r'$ 12,50');
    expect(MoneyFormatter.usd(d('1234567.891')), r'$ 1.234.567,89');
    expect(MoneyFormatter.usd(Decimal.zero), r'$ 0,00');
    expect(MoneyFormatter.usd(d('-1.25')), r'-$ 1,25');
  });

  test('VES', () {
    expect(MoneyFormatter.ves(d('10904.88')), 'Bs 10.904,88');
    expect(MoneyFormatter.ves(d('999.995')), 'Bs 1.000,00');
  });

  test('un negativo que redondea a cero no lleva signo', () {
    expect(MoneyFormatter.usd(d('-0.001')), r'$ 0,00');
  });

  test('tasa entre 2 y 4 decimales', () {
    expect(MoneyFormatter.rate(d('872.3927')), '872,3927');
    expect(MoneyFormatter.rate(d('150.0000')), '150,00');
    expect(MoneyFormatter.rate(d('1150.5')), '1.150,50');
  });

  test('cantidad sin ceros sobrantes', () {
    expect(MoneyFormatter.quantity(d('3.000')), '3');
    expect(MoneyFormatter.quantity(d('2.500')), '2,5');
    expect(MoneyFormatter.quantity(d('0.125')), '0,125');
    expect(MoneyFormatter.quantity(d('1200')), '1.200');
  });
}
