import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/domain/category.dart';
import 'package:pos_app/core/domain/enums.dart';
import 'package:pos_app/core/l10n/strings.dart';
import 'package:pos_app/core/widgets/product_card.dart';

Decimal d(String value) => Decimal.parse(value);

/// Monta una tarjeta con estado: la cantidad cambia como lo haría el carrito.
Future<List<Decimal>> pumpCard(
  WidgetTester tester, {
  required String stock,
  String quantity = '0',
  UnitOfMeasure unit = UnitOfMeasure.unit,
  String minimum = '0',
}) async {
  final changes = <Decimal>[];
  var current = d(quantity);
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 170,
              height: ProductCard.gridExtent,
              child: StatefulBuilder(
                builder: (context, setState) => ProductCard(
                  name: 'Cloro concentrado',
                  category: const ProductCategory(id: 1, name: 'Líquidos'),
                  unit: unit,
                  priceUsd: d('1.20'),
                  rate: d('150'),
                  stock: d(stock),
                  minimumStock: d(minimum),
                  quantity: current,
                  onQuantityChanged: (value) {
                    changes.add(value);
                    setState(() => current = value);
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  return changes;
}

bool isEnabled(WidgetTester tester, String tooltip) =>
    tester.widget<IconButton>(find.widgetWithIcon(IconButton, _iconOf(tooltip))).onPressed != null;

IconData _iconOf(String tooltip) =>
    tooltip == Strings.increase ? Icons.add_rounded : Icons.remove_rounded;

void main() {
  testWidgets('muestra nombre, precio en las dos monedas y stock', (tester) async {
    await pumpCard(tester, stock: '10');

    expect(find.text('Cloro concentrado'), findsOneWidget);
    expect(find.text(r'$ 1,20'), findsOneWidget);
    expect(find.text('Bs 180,00'), findsOneWidget);
    expect(find.text('10 und'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Agregar pone una unidad y aparecen los controles', (tester) async {
    final changes = await pumpCard(tester, stock: '3');

    await tester.tap(find.text(Strings.add));
    await tester.pump();

    expect(changes, [d('1')]);
    expect(find.text(Strings.add), findsNothing);
    expect(find.byTooltip(Strings.increase), findsOneWidget);
    expect(find.byTooltip(Strings.decrease), findsOneWidget);
  });

  testWidgets('el botón + no deja superar el stock disponible', (tester) async {
    final changes = await pumpCard(tester, stock: '3', quantity: '2');

    await tester.tap(find.byTooltip(Strings.increase));
    await tester.pump();
    expect(changes, [d('3')]);
    expect(isEnabled(tester, Strings.increase), isFalse);

    await tester.tap(find.byTooltip(Strings.increase), warnIfMissed: false);
    await tester.pump();
    expect(changes, [d('3')]);
  });

  testWidgets('el botón − baja de uno en uno y nunca queda negativo', (tester) async {
    final changes = await pumpCard(
      tester,
      stock: '10',
      quantity: '1.5',
      unit: UnitOfMeasure.kilogram,
    );

    await tester.tap(find.byTooltip(Strings.decrease));
    await tester.pump();
    await tester.tap(find.byTooltip(Strings.decrease));
    await tester.pump();

    expect(changes, [d('0.5'), Decimal.zero]);
    expect(find.text(Strings.add), findsOneWidget);
  });

  testWidgets('sin stock queda deshabilitada', (tester) async {
    final changes = await pumpCard(tester, stock: '0');

    expect(find.text(Strings.outOfStock), findsOneWidget);
    await tester.tap(find.text(Strings.add), warnIfMissed: false);
    await tester.pump();

    expect(changes, isEmpty);
  });

  testWidgets('a granel con menos de una unidad agrega lo que queda', (tester) async {
    final changes = await pumpCard(tester, stock: '0.750', unit: UnitOfMeasure.liter);

    await tester.tap(find.text(Strings.add));
    await tester.pump();

    expect(changes, [d('0.750')]);
    expect(isEnabled(tester, Strings.increase), isFalse);
  });

  testWidgets('a granel se puede escribir la cantidad, sin pasar del stock', (tester) async {
    final changes = await pumpCard(tester, stock: '5.5', quantity: '1', unit: UnitOfMeasure.liter);

    // La cantidad mostrada es tocable y abre el teclado decimal.
    await tester.tap(find.text('1'));
    await tester.pumpAndSettle();
    expect(find.text(Strings.quantityDialogTitle), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), '9');
    await tester.pump();
    expect(find.text(Strings.maxAvailable('5,5 L')), findsWidgets);
    expect(
      tester.widget<FilledButton>(find.widgetWithText(FilledButton, Strings.accept)).onPressed,
      isNull,
    );

    await tester.enterText(find.byType(TextFormField), '2.25');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, Strings.accept));
    await tester.pumpAndSettle();

    expect(changes, [d('2.25')]);
    expect(find.text('2,25'), findsOneWidget);
  });

  testWidgets('por unidad no se abre el teclado decimal', (tester) async {
    await pumpCard(tester, stock: '5', quantity: '1');

    await tester.tap(find.text('1'));
    await tester.pumpAndSettle();

    expect(find.text(Strings.quantityDialogTitle), findsNothing);
  });
}
