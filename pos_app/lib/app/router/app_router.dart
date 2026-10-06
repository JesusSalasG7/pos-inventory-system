import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_app/app/router/main_shell.dart';
import 'package:pos_app/app/router/route_guards.dart';
import 'package:pos_app/app/router/route_names.dart';
import 'package:pos_app/core/l10n/strings.dart';
import 'package:pos_app/core/widgets/coming_soon_screen.dart';
import 'package:pos_app/features/auth/presentation/providers/session_controller.dart';
import 'package:pos_app/features/auth/presentation/screens/branch_picker_screen.dart';
import 'package:pos_app/features/auth/presentation/screens/branch_unavailable_screen.dart';
import 'package:pos_app/features/auth/presentation/screens/first_branch_screen.dart';
import 'package:pos_app/features/auth/presentation/screens/login_screen.dart';
import 'package:pos_app/features/auth/presentation/screens/splash_screen.dart';
import 'package:pos_app/features/design_preview/presentation/design_preview_screen.dart';
import 'package:pos_app/features/home/presentation/screens/home_screen.dart';
import 'package:pos_app/features/more/presentation/screens/more_screen.dart';
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
      StatefulShellRoute.indexedStack(
        builder: (_, _, navigationShell) => MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [tab(RouteNames.home, const HomeScreen())]),
          // TODO(fase-4): POSScreen.
          StatefulShellBranch(
            routes: [tab(RouteNames.sell, const ComingSoonScreen(title: Strings.navSell))],
          ),
          // TODO(fase-5): InventoryScreen.
          StatefulShellBranch(
            routes: [
              tab(RouteNames.inventory, const ComingSoonScreen(title: Strings.navInventory)),
            ],
          ),
          // TODO(fase-3): pantallas de caja.
          StatefulShellBranch(
            routes: [tab(RouteNames.cash, const ComingSoonScreen(title: Strings.navCash))],
          ),
          StatefulShellBranch(routes: [tab(RouteNames.more, const MoreScreen())]),
        ],
      ),
    ],
  );
}
