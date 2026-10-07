import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_app/app/router/main_shell.dart';
import 'package:pos_app/app/router/route_guards.dart';
import 'package:pos_app/app/router/route_names.dart';
import 'package:pos_app/core/domain/app_user.dart';
import 'package:pos_app/features/auth/presentation/providers/session_controller.dart';
import 'package:pos_app/features/auth/presentation/screens/branch_picker_screen.dart';
import 'package:pos_app/features/auth/presentation/screens/branch_unavailable_screen.dart';
import 'package:pos_app/features/auth/presentation/screens/first_branch_screen.dart';
import 'package:pos_app/features/auth/presentation/screens/login_screen.dart';
import 'package:pos_app/features/auth/presentation/screens/splash_screen.dart';
import 'package:pos_app/features/branches/presentation/screens/branches_screen.dart';
import 'package:pos_app/features/cash_session/domain/entities/cash_session.dart';
import 'package:pos_app/features/cash_session/presentation/screens/cash_history_screen.dart';
import 'package:pos_app/features/cash_session/presentation/screens/cash_screen.dart';
import 'package:pos_app/features/cash_session/presentation/screens/close_session_screen.dart';
import 'package:pos_app/features/design_preview/presentation/design_preview_screen.dart';
import 'package:pos_app/features/exchange_rate/presentation/screens/exchange_rate_screen.dart';
import 'package:pos_app/features/home/presentation/screens/home_screen.dart';
import 'package:pos_app/features/inventory/domain/entities/product.dart';
import 'package:pos_app/features/inventory/presentation/screens/categories_screen.dart';
import 'package:pos_app/features/inventory/presentation/screens/inventory_screen.dart';
import 'package:pos_app/features/inventory/presentation/screens/movements_screen.dart';
import 'package:pos_app/features/inventory/presentation/screens/price_list_screen.dart';
import 'package:pos_app/features/inventory/presentation/screens/product_detail_screen.dart';
import 'package:pos_app/features/inventory/presentation/screens/product_form_screen.dart';
import 'package:pos_app/features/more/presentation/screens/more_screen.dart';
import 'package:pos_app/features/pos/domain/sale_receipt.dart';
import 'package:pos_app/features/pos/presentation/screens/checkout_screen.dart';
import 'package:pos_app/features/pos/presentation/screens/pos_screen.dart';
import 'package:pos_app/features/pos/presentation/screens/sale_receipt_screen.dart';
import 'package:pos_app/features/sales/domain/entities/sale.dart';
import 'package:pos_app/features/sales/presentation/screens/sale_detail_screen.dart';
import 'package:pos_app/features/sales/presentation/screens/sales_history_screen.dart';
import 'package:pos_app/features/users/presentation/screens/user_form_screen.dart';
import 'package:pos_app/features/users/presentation/screens/users_screen.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  // El router reevalúa sus redirecciones cada vez que cambia la sesión.
  final sessionChanges = ValueNotifier<int>(0);
  ref
    ..listen(sessionControllerProvider, (_, _) => sessionChanges.value++)
    ..onDispose(sessionChanges.dispose);

  GoRoute tab(String path, Widget screen) => GoRoute(
    path: path,
    pageBuilder: (_, _) => NoTransitionPage(child: screen),
  );

  return GoRouter(
    initialLocation: RouteNames.splash,
    refreshListenable: sessionChanges,
    redirect: (_, state) => RouteGuards.redirect(
      status: ref.read(sessionControllerProvider).status,
      location: state.matchedLocation,
      isDebug: kDebugMode,
    ),
    routes: [
      GoRoute(path: '/', redirect: (_, _) => RouteNames.splash),
      GoRoute(path: RouteNames.splash, builder: (_, _) => const SplashScreen()),
      GoRoute(path: RouteNames.login, builder: (_, _) => const LoginScreen()),
      GoRoute(path: RouteNames.firstBranch, builder: (_, _) => const FirstBranchScreen()),
      GoRoute(path: RouteNames.branchPicker, builder: (_, _) => const BranchPickerScreen()),
      GoRoute(
        path: RouteNames.branchUnavailable,
        builder: (_, _) => const BranchUnavailableScreen(),
      ),
      GoRoute(path: RouteNames.designPreview, builder: (_, _) => const DesignPreviewScreen()),
      GoRoute(path: RouteNames.checkout, builder: (_, _) => const CheckoutScreen()),
      GoRoute(
        path: RouteNames.saleReceipt,
        // El comprobante llega del cobro; sin él (enlace directo) se vuelve a Vender.
        redirect: (_, state) => state.extra is SaleReceipt ? null : RouteNames.sell,
        builder: (_, state) => SaleReceiptScreen(receipt: state.extra! as SaleReceipt),
      ),
      GoRoute(path: RouteNames.exchangeRate, builder: (_, _) => const ExchangeRateScreen()),
      GoRoute(path: RouteNames.cashHistory, builder: (_, _) => const CashHistoryScreen()),
      GoRoute(
        path: RouteNames.cashSessionDetail,
        // La caja llega desde la lista; sin ella (enlace directo) se vuelve al historial.
        redirect: (_, state) => state.extra is CashSession ? null : RouteNames.cashHistory,
        builder: (_, state) => CashSessionDetailScreen(session: state.extra! as CashSession),
      ),
      GoRoute(
        path: RouteNames.cashClosePattern,
        builder: (_, state) =>
            CloseSessionScreen(sessionId: int.parse(state.pathParameters['sessionId']!)),
      ),
      GoRoute(
        path: RouteNames.productDetailPattern,
        builder: (_, state) =>
            ProductDetailScreen(productId: int.parse(state.pathParameters['productId']!)),
      ),
      GoRoute(
        path: RouteNames.productForm,
        // Con un producto en `extra` edita; sin él, crea uno nuevo.
        builder: (_, state) => ProductFormScreen(product: state.extra as Product?),
      ),
      GoRoute(path: RouteNames.inventoryMovements, builder: (_, _) => const MovementsScreen()),
      GoRoute(path: RouteNames.salesHistory, builder: (_, _) => const SalesHistoryScreen()),
      GoRoute(
        path: RouteNames.saleDetail,
        // La venta llega desde la lista; sin ella (enlace directo) se vuelve al historial.
        redirect: (_, state) => state.extra is Sale ? null : RouteNames.salesHistory,
        builder: (_, state) => SaleDetailScreen(sale: state.extra! as Sale),
      ),
      GoRoute(path: RouteNames.priceList, builder: (_, _) => const PriceListScreen()),
      GoRoute(path: RouteNames.categories, builder: (_, _) => const CategoriesScreen()),
      GoRoute(path: RouteNames.users, builder: (_, _) => const UsersScreen()),
      GoRoute(
        path: RouteNames.userForm,
        // Con un usuario en `extra` edita; sin él, crea uno nuevo.
        builder: (_, state) => UserFormScreen(user: state.extra as AppUser?),
      ),
      GoRoute(path: RouteNames.branches, builder: (_, _) => const BranchesScreen()),
      StatefulShellRoute.indexedStack(
        builder: (_, _, navigationShell) => MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [tab(RouteNames.home, const HomeScreen())]),
          StatefulShellBranch(routes: [tab(RouteNames.sell, const PosScreen())]),
          StatefulShellBranch(routes: [tab(RouteNames.inventory, const InventoryScreen())]),
          StatefulShellBranch(routes: [tab(RouteNames.cash, const CashScreen())]),
          StatefulShellBranch(routes: [tab(RouteNames.more, const MoreScreen())]),
        ],
      ),
    ],
  );
}
