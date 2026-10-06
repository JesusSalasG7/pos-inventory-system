import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/app/router/route_guards.dart';
import 'package:pos_app/app/router/route_names.dart';
import 'package:pos_app/features/auth/presentation/providers/session_controller.dart';

String? go(SessionStatus status, String location, {bool isDebug = true}) =>
    RouteGuards.redirect(status: status, location: location, isDebug: isDebug);

void main() {
  test('cada estado de la sesión fuerza su pantalla', () {
    const expected = {
      SessionStatus.loading: RouteNames.splash,
      SessionStatus.error: RouteNames.splash,
      SessionStatus.unauthenticated: RouteNames.login,
      SessionStatus.needsFirstBranch: RouteNames.firstBranch,
      SessionStatus.needsBranchSelection: RouteNames.branchPicker,
      SessionStatus.branchUnavailable: RouteNames.branchUnavailable,
    };
    for (final MapEntry(key: status, value: route) in expected.entries) {
      expect(go(status, RouteNames.home), route, reason: '$status desde home');
      expect(go(status, route), isNull, reason: '$status ya en su pantalla');
    }
  });

  test('sin sesión no se puede entrar a ninguna pestaña', () {
    for (final tab in [RouteNames.sell, RouteNames.inventory, RouteNames.cash, RouteNames.more]) {
      expect(go(SessionStatus.unauthenticated, tab), RouteNames.login);
    }
  });

  test('con la sesión lista, las pantallas de entrada llevan a Inicio', () {
    for (final gate in [
      '/',
      RouteNames.splash,
      RouteNames.login,
      RouteNames.firstBranch,
      RouteNames.branchPicker,
      RouteNames.branchUnavailable,
    ]) {
      expect(go(SessionStatus.ready, gate), RouteNames.home);
    }
    expect(go(SessionStatus.ready, RouteNames.sell), isNull);
    expect(go(SessionStatus.ready, RouteNames.more), isNull);
  });

  test('la vista previa de diseño solo existe en depuración', () {
    expect(go(SessionStatus.unauthenticated, RouteNames.designPreview), isNull);
    expect(go(SessionStatus.ready, RouteNames.designPreview), isNull);
    expect(go(SessionStatus.ready, RouteNames.designPreview, isDebug: false), RouteNames.splash);
  });
}
