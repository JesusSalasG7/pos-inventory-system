import 'package:decimal/decimal.dart';

/// Formato de montos para la UI, al estilo venezolano: miles con punto y
/// decimales con coma. Trabaja sobre el texto del `Decimal`, sin pasar por `double`.
abstract final class MoneyFormatter {
  /// `$ 12,50`
  static String usd(Decimal amount) => _signed(amount, r'$ ', 2, 2);

  /// `Bs 10.904,88`
  static String ves(Decimal amount) => _signed(amount, 'Bs ', 2, 2);

  /// Tasa de cambio: entre 2 y 4 decimales, `872,3927`.
  static String rate(Decimal rate) => number(rate, minDecimals: 2, maxDecimals: 4);

  /// Cantidad de stock sin ceros sobrantes: `3`, `2,5`, `0,125`.
  static String quantity(Decimal quantity) => number(quantity, maxDecimals: 3);

  /// Número con separador de miles y entre `minDecimals` y `maxDecimals` decimales.
  static String number(Decimal value, {int minDecimals = 0, int maxDecimals = 2}) {
    assert(minDecimals <= maxDecimals, 'minDecimals no puede superar maxDecimals');
    final rounded = value.round(scale: maxDecimals);
    final negative = rounded < Decimal.zero;
    final parts = rounded.abs().toStringAsFixed(maxDecimals).split('.');
    var fraction = parts.length > 1 ? parts[1] : '';
    while (fraction.length > minDecimals && fraction.endsWith('0')) {
      fraction = fraction.substring(0, fraction.length - 1);
    }
    final text = fraction.isEmpty ? _group(parts[0]) : '${_group(parts[0])},$fraction';
    return negative ? '-$text' : text;
  }

  static String _signed(Decimal amount, String symbol, int min, int max) {
    final text = number(amount.abs(), minDecimals: min, maxDecimals: max);
    final isNegative = amount.round(scale: max) < Decimal.zero;
    return isNegative ? '-$symbol$text' : '$symbol$text';
  }

  static String _group(String digits) {
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }
}
