import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/l10n/strings.dart';
import 'package:pos_app/core/theme/app_theme.dart';
import 'package:pos_app/features/cash_session/presentation/providers/current_session_provider.dart';
import 'package:pos_app/features/cash_session/presentation/screens/close_session_screen.dart';

import '../mocks/fake_repositories.dart';
import '../mocks/test_fonts.dart';

void main() {
  setUpAll(loadAppFonts);

  late FakeCashSessionRepository cash;
  late ProviderContainer container;

  Future<void> pumpClose(WidgetTester tester, {String? rate = '150'}) async {
    tester.view.physicalSize = const Size(393, 1400) * 2;
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    cash = FakeCashSessionRepository(rate: dec('150'))..cashSalesVes = dec('3000');
    container = ProviderContainer(
      retry: (_, _) => null,
      overrides: sessionOverrides(
        auth: FakeAuthRepository(user: supervisor(), hasSession: true),
        branches: FakeBranchRepository([villaLibertad]),
        rate: rate == null ? null : dec(rate),
        cash: cash,
      ),
    );
    addTearDown(container.dispose);
    // La preparación usa futuros reales: fuera del reloj simulado del test.
    final session = (await tester.runAsync(() async {
      await settledSession(container);
      await container.read(currentSessionProvider.future);
      return container.read(currentSessionProvider.notifier).open(openingFloat: dec('120'));
    }))!;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light,
          home: Navigator(
            onGenerateRoute: (_) =>
                MaterialPageRoute<void>(builder: (_) => CloseSessionScreen(sessionId: session.id)),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder field(String label) => find.widgetWithText(TextFormField, label);

  testWidgets('muestra lo esperado en cada moneda', (tester) async {
    await pumpClose(tester);

    expect(find.text(r'$ 120,00'), findsWidgets);
    expect(find.text('Bs 3.000,00'), findsWidgets);
    expect(find.text(Strings.electronicNote), findsOneWidget);
  });

  testWidgets('estima la diferencia en vivo: faltante en rojo, sobrante en verde', (tester) async {
    await pumpClose(tester);

    await tester.enterText(field(Strings.countedUsd), '120');
    await tester.enterText(field(Strings.countedVes), '2700');
    await tester.pump();
    expect(find.text('${Strings.shortage}  \$ 2,00'), findsOneWidget);

    await tester.enterText(field(Strings.countedVes), '3000');
    await tester.pump();
    expect(find.text('${Strings.balanced}  \$ 0,00'), findsOneWidget);

    await tester.enterText(field(Strings.countedUsd), '125,5');
    await tester.pump();
    expect(find.text('${Strings.surplus}  \$ 5,50'), findsOneWidget);
  });

  testWidgets('no cierra sin los dos montos contados', (tester) async {
    await pumpClose(tester);

    await tester.tap(find.widgetWithText(FilledButton, Strings.closeCash));
    await tester.pumpAndSettle();

    expect(find.text(Strings.amountRequired), findsNWidgets(2));
    expect(find.text(Strings.closeCashConfirmTitle), findsNothing);
    expect(cash.current, isNotNull);
  });

  testWidgets('pide confirmación y muestra la diferencia definitiva del backend', (tester) async {
    await pumpClose(tester);
    // El backend cierra con otra tasa: su diferencia no coincide con la estimada.
    cash.rate = dec('100');

    await tester.enterText(field(Strings.countedUsd), '120');
    await tester.enterText(field(Strings.countedVes), '2700');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, Strings.closeCash));
    await tester.pumpAndSettle();

    expect(find.text(Strings.closeCashConfirmTitle), findsOneWidget);
    expect(cash.current, isNotNull);

    await tester.tap(find.widgetWithText(FilledButton, Strings.closeCash).last);
    // El botón sigue girando bajo el diálogo de resultado: no hay reposo que esperar.
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text(Strings.cashClosedTitle), findsOneWidget);
    expect(find.text('${Strings.shortage}  \$ 3,00'), findsOneWidget);
    expect(cash.current, isNull);
    expect(container.read(currentSessionProvider).value, isNull);
  });

  testWidgets('sin tasa activa no se puede cerrar', (tester) async {
    await pumpClose(tester, rate: null);

    expect(find.text(Strings.noRateForCount), findsOneWidget);
    expect(
      tester.widget<FilledButton>(find.widgetWithText(FilledButton, Strings.closeCash)).onPressed,
      isNull,
    );
  });
}
