import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../test/flows/main_flow.dart';

/// Test de integración: el mismo recorrido principal, pero en un teléfono
/// real. No necesita servidor (usa los repositorios falsos).
///
///     flutter test integration_test/app_flow_test.dart -d <id del teléfono>
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(initializeDateFormatting);

  testWidgets('recorrido principal en el dispositivo', runMainFlow);
}
