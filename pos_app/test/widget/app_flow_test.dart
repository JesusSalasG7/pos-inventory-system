import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../flows/main_flow.dart';
import '../mocks/test_fonts.dart';

void main() {
  setUpAll(() async {
    await loadAppFonts();
    await initializeDateFormatting();
  });

  testWidgets('recorrido principal: ingresar, abrir caja, vender y consultar', (tester) async {
    // Tamaño de un teléfono Android corriente.
    tester.view.physicalSize = const Size(393, 851) * 2.75;
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);

    await runMainFlow(tester);
  });
}
