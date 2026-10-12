import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';
import 'package:pos_app/core/currency/money_formatter.dart';
import 'package:pos_app/core/domain/enums.dart';
import 'package:pos_app/core/l10n/strings.dart';

/// Formatos propios de las estadísticas: porcentajes, variaciones y ejes.
abstract final class StatsFormat {
  static final NumberFormat _compact = NumberFormat('0.#', 'es');

  /// `26,92 %`
  static String percent(Decimal value) => '${MoneyFormatter.number(value)} %';

  /// Variación sin signo, con un decimal: `12,5 %` o, para el margen, `3,2 pp`.
  static String change(Decimal value, {bool inPoints = false}) =>
      '${MoneyFormatter.number(value.abs(), maxDecimals: 1)} ${inPoints ? 'pp' : '%'}';

  /// Cantidad con su unidad: `2,5 L`.
  static String quantity(Decimal value, UnitOfMeasure unit) =>
      '${MoneyFormatter.quantity(value)} ${Strings.unitShort(unit)}';

  /// Número compacto para los ejes: `850`, `1,2 K`, `3,4 M`.
  static String compact(double value) {
    final magnitude = value.abs();
    if (magnitude >= 1000000) return '${_compact.format(value / 1000000)} M';
    if (magnitude >= 1000) return '${_compact.format(value / 1000)} K';
    return _compact.format(value);
  }
}
