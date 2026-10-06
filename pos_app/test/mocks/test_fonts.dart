import 'dart:io';

import 'package:flutter/services.dart';

/// Carga la tipografía real de la app en los tests de widgets.
///
/// Sin esto Flutter usa la fuente de pruebas "Ahem", cuyos glifos son
/// cuadrados y mucho más anchos: daría desbordes que no existen en el teléfono.
Future<void> loadAppFonts() async {
  final loader = FontLoader('Manrope');
  for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold', 'ExtraBold']) {
    final bytes = File('assets/fonts/Manrope-$weight.ttf').readAsBytesSync();
    loader.addFont(Future.value(ByteData.sublistView(bytes)));
  }
  await loader.load();
}
