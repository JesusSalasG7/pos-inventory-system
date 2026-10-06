import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_app/app/router/route_guards.dart';
import 'package:pos_app/app/router/route_names.dart';
import 'package:pos_app/core/l10n/strings.dart';
import 'package:pos_app/core/widgets/empty_state.dart';
import 'package:pos_app/features/design_preview/presentation/design_preview_screen.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  return GoRouter(
    initialLocation: RouteNames.root,
    routes: [
      GoRoute(
        path: RouteNames.root,
        // Fase 1: aún no hay login; en depuración se abre la vista previa de diseño.
        redirect: (_, _) => kDebugMode ? RouteNames.designPreview : null,
        builder: (_, _) => const Scaffold(
          body: EmptyState(
            icon: Icons.construction_rounded,
            title: Strings.appName,
            message: Strings.underConstruction,
          ),
        ),
      ),
      GoRoute(
        path: RouteNames.designPreview,
        redirect: (_, _) => RouteGuards.debugOnly(),
        builder: (_, _) => const DesignPreviewScreen(),
      ),
    ],
  );
}
