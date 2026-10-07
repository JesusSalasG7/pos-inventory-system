import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/domain/enums.dart';
import 'package:pos_app/core/errors/failure.dart';
import 'package:pos_app/core/l10n/strings.dart';
import 'package:pos_app/core/theme/app_theme.dart';
import 'package:pos_app/features/inventory/domain/entities/product.dart';
import 'package:pos_app/features/inventory/presentation/providers/inventory_providers.dart';
import 'package:pos_app/features/inventory/presentation/screens/product_form_screen.dart';

import '../mocks/fake_repositories.dart';
import '../mocks/test_fonts.dart';

void main() {
  setUpAll(loadAppFonts);

  final chlorine = product(1, 'Cloro', price: '1.20', unit: UnitOfMeasure.liter);
  late FakeInventoryRepository inventory;
  bool? result;

  /// Monta una pantalla de partida y abre el formulario encima, como en la app.
  Future<void> pumpForm(WidgetTester tester, {Product? editing}) async {
    tester.view.physicalSize = const Size(393, 1600) * 2;
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    result = null;
    inventory = FakeInventoryRepository()..seed('VILLA_LIBERTAD', [stocked(chlorine, '10')]);
    final container = ProviderContainer(
      retry: (_, _) => null,
      overrides: sessionOverrides(
        auth: FakeAuthRepository(user: manager(), hasSession: true),
        branches: FakeBranchRepository([villaLibertad]),
        rate: dec('150'),
        inventory: inventory,
      ),
    );
    addTearDown(container.dispose);
    container.listen(inventoryCatalogProvider, (_, _) {});
    await tester.runAsync(() => settledSession(container));

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light,
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(builder: (_) => ProductFormScreen(product: editing)),
                );
              },
              child: const Text('abrir'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
  }

  Finder field(String label) => find.widgetWithText(TextFormField, label);

  testWidgets('no guarda sin nombre, categoría ni precios', (tester) async {
    await pumpForm(tester);

    await tester.tap(find.widgetWithText(FilledButton, Strings.createProduct));
    await tester.pumpAndSettle();

    expect(find.text(Strings.productNameRequired), findsOneWidget);
    expect(find.text(Strings.categoryRequired), findsOneWidget);
    expect(find.text(Strings.priceRequired), findsNWidgets(2));
    expect(inventory.products, hasLength(1));
  });

  testWidgets('crea un producto con precios en Decimal y vuelve atrás', (tester) async {
    await pumpForm(tester);

    await tester.enterText(field(Strings.productName), '  Desengrasante ');
    await tester.tap(find.text(Strings.categoryLabel));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Polvos').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text(Strings.unit(UnitOfMeasure.liter)));
    await tester.enterText(field(Strings.costPriceLabel), '1,1');
    await tester.enterText(field(Strings.salePriceLabel), '2,35');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, Strings.createProduct));
    await tester.pumpAndSettle();

    final created = inventory.products.last;
    expect(created.name, 'Desengrasante');
    expect(created.category.id, powders.id);
    expect(created.unit, UnitOfMeasure.liter);
    expect(created.costPriceUsd, dec('1.10'));
    expect(created.salePriceUsd, dec('2.35'));
    expect(result, isTrue);
  });

  testWidgets('al editar parte de los datos actuales y avisa si se vende bajo el costo', (
    tester,
  ) async {
    await pumpForm(tester, editing: chlorine);

    expect(find.text('Cloro'), findsOneWidget);
    await tester.enterText(field(Strings.salePriceLabel), '0,4');
    await tester.pump();
    expect(find.text(Strings.saleBelowCost), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, Strings.saveChanges));
    await tester.pumpAndSettle();

    expect(inventory.products.single.salePriceUsd, dec('0.40'));
    expect(inventory.products.single.id, chlorine.id);
  });

  testWidgets('muestra el error del backend y no cierra el formulario', (tester) async {
    await pumpForm(tester, editing: chlorine);
    inventory.writeFailure = const Failure(
      code: 'product_name_taken',
      message: 'Ya existe un producto con ese nombre.',
    );

    await tester.tap(find.widgetWithText(FilledButton, Strings.saveChanges));
    await tester.pumpAndSettle();

    expect(find.text('Ya existe un producto con ese nombre.'), findsOneWidget);
    expect(result, isNull);
  });
}
