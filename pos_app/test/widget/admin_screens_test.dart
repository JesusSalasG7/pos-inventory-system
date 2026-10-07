import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:pos_app/core/domain/app_user.dart';
import 'package:pos_app/core/domain/category.dart';
import 'package:pos_app/core/domain/enums.dart';
import 'package:pos_app/core/l10n/strings.dart';
import 'package:pos_app/core/storage/branch_preference_storage.dart';
import 'package:pos_app/core/theme/app_theme.dart';
import 'package:pos_app/features/branches/presentation/screens/branches_screen.dart';
import 'package:pos_app/features/exchange_rate/presentation/providers/active_rate_provider.dart';
import 'package:pos_app/features/inventory/presentation/screens/categories_screen.dart';
import 'package:pos_app/features/sales/domain/entities/sale.dart';
import 'package:pos_app/features/sales/presentation/screens/sales_history_screen.dart';
import 'package:pos_app/features/users/presentation/screens/user_form_screen.dart';

import '../mocks/fake_repositories.dart';
import '../mocks/test_fonts.dart';

void main() {
  setUpAll(() async {
    await loadAppFonts();
    await initializeDateFormatting();
  });

  late FakeInventoryRepository inventory;
  late FakeSalesRepository sales;
  late FakeBranchRepository branches;
  late FakeUsersRepository users;
  bool? result;

  /// Monta una pantalla de partida y abre `screen` encima, como en la app.
  Future<void> pump(WidgetTester tester, Widget screen) async {
    tester.view.physicalSize = const Size(393, 1800) * 2;
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    result = null;
    final container = ProviderContainer(
      retry: (_, _) => null,
      overrides: sessionOverrides(
        auth: FakeAuthRepository(user: manager(), hasSession: true),
        branches: branches,
        preference: InMemoryBranchPreferenceStorage('VILLA_LIBERTAD'),
        rate: dec('150'),
        inventory: inventory,
        sales: sales,
        users: users,
      ),
    );
    addTearDown(container.dispose);
    await tester.runAsync(() async {
      await settledSession(container);
      await container.read(activeRateProvider.future);
    });

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light,
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result = await Navigator.of(
                  context,
                ).push<bool>(MaterialPageRoute(builder: (_) => screen));
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

  /// La sesión se preparó con el reloj real (`runAsync`): las recargas tras
  /// guardar necesitan que corra de nuevo antes de volver a pintar.
  Future<void> settleReload(WidgetTester tester) async {
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pumpAndSettle();
  }

  Finder field(String label) => find.widgetWithText(TextFormField, label);

  setUp(() {
    inventory = FakeInventoryRepository();
    sales = FakeSalesRepository();
    branches = FakeBranchRepository([villaLibertad, lasAmericas]);
    users = FakeUsersRepository([manager(), supervisor()]);
  });

  group('ventas del día', () {
    Sale saleNow(int id, DateTime createdAt) => Sale(
      id: id,
      cashSessionId: 1,
      userId: 2,
      branchCode: 'VILLA_LIBERTAD',
      customerTaxId: '',
      customerName: 'Ana Pérez',
      exchangeRateAtInvoice: dec('100'),
      totalUsd: dec('7.50'),
      totalVes: dec('750.00'),
      createdAt: createdAt,
      details: const [],
      payments: [
        SalePayment(
          id: 1,
          method: PaymentMethod.mobilePayment,
          currency: Currency.ves,
          amount: dec('750.00'),
          approvalReference: '0045',
        ),
      ],
    );

    testWidgets('muestra las ventas de hoy con la tasa con la que se facturaron', (tester) async {
      sales.sales.add(saleNow(12, DateTime.now()));
      await pump(tester, const SalesHistoryScreen());

      expect(find.textContaining(Strings.saleNumber(12)), findsOneWidget);
      expect(find.text(Strings.paymentMethod(PaymentMethod.mobilePayment)), findsOneWidget);
      // 7,50 $ a la tasa de la venta (100), no a la activa (150).
      expect(find.text('Bs 750,00'), findsOneWidget);
      expect(find.text('Bs 1.125,00'), findsNothing);
      expect(find.textContaining('Ana Pérez'), findsOneWidget);
    });

    testWidgets('el día anterior sin ventas muestra el estado vacío', (tester) async {
      sales.sales.add(saleNow(12, DateTime.now()));
      await pump(tester, const SalesHistoryScreen());

      await tester.tap(find.byTooltip(Strings.previousDay));
      await tester.pumpAndSettle();
      await settleReload(tester);

      expect(find.text(Strings.emptySalesTitle), findsOneWidget);
      expect(find.textContaining(Strings.saleNumber(12)), findsNothing);
    });

    testWidgets('no deja avanzar más allá de hoy', (tester) async {
      await pump(tester, const SalesHistoryScreen());

      final next = find.widgetWithIcon(IconButton, Icons.chevron_right_rounded);
      expect(tester.widget<IconButton>(next).onPressed, isNull);
    });
  });

  group('categorías', () {
    testWidgets('crea una categoría desde el diálogo', (tester) async {
      await pump(tester, const CategoriesScreen());
      expect(find.text('Líquidos'), findsOneWidget);

      await tester.tap(find.text(Strings.newCategory));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, Strings.save));
      await tester.pumpAndSettle();
      expect(find.text(Strings.categoryNameRequired), findsOneWidget);

      await tester.enterText(field(Strings.categoryName), 'Aromatizantes');
      await tester.tap(find.widgetWithText(FilledButton, Strings.save));
      await tester.pumpAndSettle();
      await settleReload(tester);

      expect(find.text('Aromatizantes'), findsOneWidget);
      expect(find.text(Strings.categoryCreated), findsOneWidget);
    });

    testWidgets('el nombre repetido muestra el error y deja el diálogo abierto', (tester) async {
      await pump(tester, const CategoriesScreen());

      await tester.tap(find.text(Strings.newCategory));
      await tester.pumpAndSettle();
      await tester.enterText(field(Strings.categoryName), 'polvos');
      await tester.tap(find.widgetWithText(FilledButton, Strings.save));
      await tester.pumpAndSettle();

      expect(find.text('Ya existe una categoría con ese nombre.'), findsOneWidget);
      expect(inventory.categories, hasLength(3));
    });

    testWidgets('el interruptor desactiva la categoría sin borrarla', (tester) async {
      inventory.categories = [const ProductCategory(id: 1, name: 'Líquidos')];
      await pump(tester, const CategoriesScreen());

      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      await settleReload(tester);

      expect(inventory.categories.single.active, isFalse);
      expect(find.text(Strings.inactiveCategory), findsOneWidget);
    });
  });

  group('tiendas', () {
    testWidgets('la tienda en uso no se puede desactivar desde aquí', (tester) async {
      await pump(tester, const BranchesScreen());

      final switches = tester.widgetList<Switch>(find.byType(Switch)).toList();
      // Orden de la lista: Villa Libertad (en uso) y Las Américas.
      expect(switches.first.onChanged, isNull);
      expect(switches.last.onChanged, isNotNull);
      expect(find.textContaining(Strings.branchInUse), findsOneWidget);
    });

    testWidgets('crea una tienda proponiendo el código a partir del nombre', (tester) async {
      await pump(tester, const BranchesScreen());

      await tester.tap(find.text(Strings.newBranch));
      await tester.pumpAndSettle();
      await tester.enterText(field(Strings.branchName), 'Sede Centro');
      await tester.pump();
      expect(find.text('SEDE_CENTRO'), findsOneWidget);
      await tester.tap(find.widgetWithText(FilledButton, Strings.save));
      await tester.pumpAndSettle();
      await settleReload(tester);

      expect(branches.branches.map((b) => b.code), contains('SEDE_CENTRO'));
      expect(find.text('Sede Centro'), findsOneWidget);
    });
  });

  group('formulario de usuario', () {
    AppUser created() => users.users.last;

    testWidgets('un supervisor necesita una tienda y una contraseña de 8 caracteres', (
      tester,
    ) async {
      await pump(tester, const UserFormScreen());

      await tester.enterText(field(Strings.fullName), 'Marta Caja');
      await tester.enterText(field(Strings.username), 'caja2');
      await tester.enterText(field(Strings.password), 'corta');
      await tester.tap(find.widgetWithText(FilledButton, Strings.createUser));
      await tester.pumpAndSettle();

      expect(find.text(Strings.userBranchRequired), findsOneWidget);
      expect(find.text(Strings.passwordTooShort(8)), findsWidgets);
      expect(users.users, hasLength(2));
    });

    testWidgets('"Todas las tiendas" solo se ofrece a un gerente', (tester) async {
      await pump(tester, const UserFormScreen());

      await tester.tap(find.text(Strings.userBranch));
      await tester.pumpAndSettle();
      expect(find.text(Strings.allBranches), findsNothing);
      await tester.tap(find.text('Las Américas').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text(Strings.role(UserRole.manager)));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Las Américas'));
      await tester.pumpAndSettle();
      expect(find.text(Strings.allBranches), findsOneWidget);
      await tester.tap(find.text(Strings.allBranches).last);
      await tester.pumpAndSettle();

      await tester.enterText(field(Strings.fullName), 'Carlos Socio');
      await tester.enterText(field(Strings.username), 'socio');
      await tester.enterText(field(Strings.password), 'clave-segura');
      await tester.tap(find.widgetWithText(FilledButton, Strings.createUser));
      await tester.pumpAndSettle();

      expect(created().role, UserRole.manager);
      expect(created().assignedBranch, isNull);
      expect(result, isTrue);
    });

    testWidgets('al editar no cambia la contraseña si se deja vacía', (tester) async {
      await pump(tester, UserFormScreen(user: supervisor()));

      await tester.enterText(field(Strings.fullName), 'Luis Alberto Supervisor');
      await tester.tap(find.widgetWithText(FilledButton, Strings.saveChanges));
      await tester.pumpAndSettle();

      final saved = users.users.firstWhere((user) => user.id == 2);
      expect(saved.fullName, 'Luis Alberto Supervisor');
      expect(saved.assignedBranch, 'VILLA_LIBERTAD');
      expect(users.passwords, isEmpty);
    });

    testWidgets('un gerente no puede desactivarse ni quitarse el rol', (tester) async {
      await pump(tester, UserFormScreen(user: manager()));

      expect(find.text(Strings.cannotDeactivateSelf), findsOneWidget);
      expect(tester.widget<SwitchListTile>(find.byType(SwitchListTile)).onChanged, isNull);
    });
  });
}
