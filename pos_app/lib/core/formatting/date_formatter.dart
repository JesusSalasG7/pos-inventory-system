import 'package:intl/intl.dart';

/// Fechas para la UI en hora de Venezuela (America/Caracas, UTC−4, sin horario de verano).
abstract final class DateFormatter {
  static const String locale = 'es_VE';
  static const Duration _caracasOffset = Duration(hours: -4);

  /// Lleva un instante a la hora de pared de Caracas.
  static DateTime toCaracas(DateTime instant) => instant.toUtc().add(_caracasOffset);

  /// Ahora mismo, en hora de pared de Caracas.
  static DateTime nowInCaracas() => toCaracas(DateTime.now());

  /// Instante en que empieza el día de Caracas que contiene a `instant`.
  static DateTime startOfCaracasDay(DateTime instant) {
    final local = toCaracas(instant);
    return DateTime.utc(local.year, local.month, local.day).subtract(_caracasOffset);
  }

  /// `06/10/2026`
  static String date(DateTime instant) =>
      DateFormat('dd/MM/yyyy', locale).format(toCaracas(instant));

  /// `10:15 a. m.`
  static String time(DateTime instant) => DateFormat('h:mm a', locale).format(toCaracas(instant));

  /// `06/10/2026 10:15 a. m.`
  static String dateTime(DateTime instant) => '${date(instant)} ${time(instant)}';

  /// Fecha de calendario (sin hora ni zona), como el `effective_date` de una
  /// tasa: se muestra tal cual, sin convertirla a ninguna zona horaria.
  static String calendarDate(DateTime day) => DateFormat('dd/MM/yyyy', locale).format(day);

  /// `06/10`: día y mes de una fecha de calendario, para espacios estrechos.
  static String calendarDayMonth(DateTime day) => DateFormat('dd/MM', locale).format(day);

  /// Fecha de calendario de Caracas de un instante.
  static DateTime caracasDay(DateTime instant) {
    final local = toCaracas(instant);
    return DateTime(local.year, local.month, local.day);
  }

  /// Instante en que empieza en Caracas una fecha de calendario.
  static DateTime startOfCalendarDay(DateTime day) =>
      DateTime.utc(day.year, day.month, day.day).subtract(_caracasOffset);

  /// Último instante de una fecha de calendario en Caracas. Los filtros de
  /// fecha del backend incluyen el extremo final.
  static DateTime endOfCalendarDay(DateTime day) => startOfCalendarDay(
    day,
  ).add(const Duration(days: 1)).subtract(const Duration(microseconds: 1));

  /// `martes 6 de octubre`: fecha de calendario escrita, para encabezados.
  static String calendarLongDate(DateTime day) =>
      DateFormat("EEEE d 'de' MMMM", locale).format(day);

  /// Instante en ISO 8601 con zona, como lo espera la API en los filtros de fecha.
  static String toApi(DateTime instant) => instant.toUtc().toIso8601String();
}
