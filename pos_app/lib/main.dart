import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:pos_app/app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  runApp(
    ProviderScope(
      // Riverpod reintenta por defecto los providers que fallan. Aquí un fallo
      // suele ser una regla de negocio del backend (409, 422…), que no se
      // arregla reintentando: se muestra el error y el usuario decide.
      retry: (_, _) => null,
      child: const PosApp(),
    ),
  );
}
