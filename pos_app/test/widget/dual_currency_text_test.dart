import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/l10n/strings.dart';
import 'package:pos_app/core/widgets/dual_currency_text.dart';
import 'package:pos_app/features/exchange_rate/presentation/providers/active_rate_provider.dart';

Decimal d(String value) => Decimal.parse(value);

Future<void> pumpText(WidgetTester tester, Widget child, {Decimal? activeRate}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [activeRateProvider.overrideWithBuild((ref, notifier) => activeRate)],
      child: MaterialApp(home: Scaffold(body: child)),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('usa la tasa activa por defecto', (tester) async {
    await pumpText(tester, DualCurrencyText(amountUsd: d('10')), activeRate: d('200'));

    expect(find.text(r'$ 10,00'), findsOneWidget);
    expect(find.text('Bs 2.000,00'), findsOneWidget);
  });

  testWidgets('con tasa congelada ignora la tasa activa', (tester) async {
    await pumpText(
      tester,
      DualCurrencyText(amountUsd: d('10'), rate: d('150')),
      activeRate: d('200'),
    );

    expect(find.text('Bs 1.500,00'), findsOneWidget);
    expect(find.text('Bs 2.000,00'), findsNothing);
  });

  testWidgets('sin tasa muestra solo el monto en USD', (tester) async {
    await pumpText(tester, DualCurrencyText(amountUsd: d('12.5')));

    expect(find.text(r'$ 12,50'), findsOneWidget);
    expect(find.text(Strings.vesUnavailable), findsOneWidget);
  });

  testWidgets('con bolívares del backend no convierte nada', (tester) async {
    await pumpText(
      tester,
      DualCurrencyText(amountUsd: d('10'), amountVes: d('1480.25')),
      activeRate: d('200'),
    );

    expect(find.text('Bs 1.480,25'), findsOneWidget);
    expect(find.text('Bs 2.000,00'), findsNothing);
  });

  testWidgets('el USD va destacado y el VES más pequeño, con cifras tabulares', (tester) async {
    await pumpText(
      tester,
      DualCurrencyText(amountUsd: d('10'), rate: d('150'), size: DualCurrencySize.large),
    );

    final usd = tester.widget<Text>(find.text(r'$ 10,00')).style!;
    final ves = tester.widget<Text>(find.text('Bs 1.500,00')).style!;
    expect(usd.fontSize, greaterThan(ves.fontSize!));
    expect(usd.fontWeight!.value, greaterThan(ves.fontWeight!.value));
    expect(usd.fontFeatures, contains(const FontFeature.tabularFigures()));
    expect(ves.fontFeatures, contains(const FontFeature.tabularFigures()));
  });
}
