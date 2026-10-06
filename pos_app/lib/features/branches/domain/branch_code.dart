/// Reglas del `code` de una sucursal, las mismas que valida el backend:
/// mayúsculas, empieza por letra, solo letras, números y guion bajo, máximo 20.
abstract final class BranchCode {
  static const int maxLength = 20;
  static final RegExp _pattern = RegExp(r'^[A-Z][A-Z0-9_]{0,19}$');
  static const Map<String, String> _plain = {
    'Á': 'A',
    'É': 'E',
    'Í': 'I',
    'Ó': 'O',
    'Ú': 'U',
    'Ü': 'U',
    'Ñ': 'N',
  };

  static bool isValid(String code) => _pattern.hasMatch(code);

  /// Propone un código a partir del nombre: `Sede Las Américas` → `SEDE_LAS_AMERICAS`.
  /// Devuelve cadena vacía si el nombre no tiene letras ni números.
  static String suggest(String name) {
    final upper = name.trim().toUpperCase().split('').map((c) => _plain[c] ?? c).join();
    var code = upper.replaceAll(RegExp('[^A-Z0-9]+'), '_').replaceAll(RegExp(r'^_+|_+$'), '');
    if (code.isEmpty) return '';
    // El backend exige que empiece por letra.
    if (RegExp(r'^\d').hasMatch(code)) code = 'S$code';
    if (code.length > maxLength) code = code.substring(0, maxLength);
    return code.replaceAll(RegExp(r'_+$'), '');
  }
}
