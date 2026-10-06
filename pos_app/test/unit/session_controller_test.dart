import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/errors/failure.dart';
import 'package:pos_app/core/session/active_branch_provider.dart';
import 'package:pos_app/core/session/current_user_provider.dart';
import 'package:pos_app/core/session/session_expired_provider.dart';
import 'package:pos_app/core/storage/branch_preference_storage.dart';
import 'package:pos_app/features/auth/presentation/providers/session_controller.dart';

import '../mocks/fake_repositories.dart';

void main() {
  late FakeAuthRepository auth;
  late FakeBranchRepository branches;
  late InMemoryBranchPreferenceStorage preference;

  ProviderContainer makeContainer() {
    final container = ProviderContainer(
      retry: (_, _) => null,
      overrides: sessionOverrides(auth: auth, branches: branches, preference: preference),
    );
    addTearDown(container.dispose);
    return container;
  }

  setUp(() {
    auth = FakeAuthRepository();
    branches = FakeBranchRepository([villaLibertad, lasAmericas]);
    preference = InMemoryBranchPreferenceStorage();
  });

  group('arranque', () {
    test('sin sesión guardada va al login, sin llamar al backend', () async {
      final container = makeContainer();

      final state = await settledSession(container);

      expect(state.status, SessionStatus.unauthenticated);
      expect(container.read(currentUserProvider), isNull);
      expect(container.read(activeBranchProvider), isNull);
    });

    test('un SUPERVISOR entra directo a su sucursal asignada', () async {
      auth
        ..hasSession = true
        ..user = supervisor(assignedBranch: 'LAS_AMERICAS');
      final container = makeContainer();

      final state = await settledSession(container);

      expect(state.status, SessionStatus.ready);
      expect(container.read(activeBranchProvider), lasAmericas);
      expect(container.read(currentUserProvider)!.isManager, isFalse);
    });

    test('un MANAGER con una sola sucursal activa no tiene que elegir', () async {
      auth
        ..hasSession = true
        ..user = manager();
      branches.branches = [villaLibertad];
      final container = makeContainer();

      final state = await settledSession(container);

      expect(state.status, SessionStatus.ready);
      expect(container.read(activeBranchProvider), villaLibertad);
    });

    test('un MANAGER con varias sucursales debe elegir una', () async {
      auth
        ..hasSession = true
        ..user = manager();
      final container = makeContainer();

      final state = await settledSession(container);

      expect(state.status, SessionStatus.needsBranchSelection);
      expect(state.branches, [villaLibertad, lasAmericas]);
      expect(container.read(activeBranchProvider), isNull);

      await container.read(sessionControllerProvider.notifier).selectBranch(lasAmericas);

      expect(container.read(sessionControllerProvider).status, SessionStatus.ready);
      expect(container.read(activeBranchProvider), lasAmericas);
      expect(preference.branchCode, 'LAS_AMERICAS');
    });

    test('recuerda la última sucursal elegida, si sigue activa', () async {
      auth
        ..hasSession = true
        ..user = manager();
      preference.branchCode = 'LAS_AMERICAS';
      final container = makeContainer();

      expect((await settledSession(container)).status, SessionStatus.ready);
      expect(container.read(activeBranchProvider), lasAmericas);

      // Si la recordada ya no existe, vuelve a preguntar.
      preference.branchCode = 'CERRADA';
      await container.read(sessionControllerProvider.notifier).bootstrap();
      expect(container.read(sessionControllerProvider).status, SessionStatus.needsBranchSelection);
    });

    test('un MANAGER con sucursal asignada no elige aunque haya varias', () async {
      auth
        ..hasSession = true
        ..user = manager(assignedBranch: 'VILLA_LIBERTAD');
      final container = makeContainer();

      expect((await settledSession(container)).status, SessionStatus.ready);
      expect(container.read(activeBranchProvider), villaLibertad);
    });

    test('la sucursal asignada inactiva deja al usuario sin poder operar', () async {
      auth
        ..hasSession = true
        ..user = supervisor(assignedBranch: 'CERRADA');
      final container = makeContainer();

      final state = await settledSession(container);

      expect(state.status, SessionStatus.branchUnavailable);
      expect(container.read(activeBranchProvider), isNull);
    });

    test('sin conexión queda en error y se puede reintentar', () async {
      auth
        ..hasSession = true
        ..user = supervisor()
        ..fetchUserFailure = offline;
      final container = makeContainer();

      final state = await settledSession(container);
      expect(state.status, SessionStatus.error);
      expect(state.failure, offline);
      expect(auth.logoutCalls, 0);

      auth.fetchUserFailure = null;
      await container.read(sessionControllerProvider.notifier).bootstrap();
      expect(container.read(sessionControllerProvider).status, SessionStatus.ready);
    });

    test('si el refresh venció (401) borra la sesión y va al login', () async {
      auth
        ..hasSession = true
        ..fetchUserFailure = const Failure(code: 'token_not_valid', message: 'x', statusCode: 401);
      final container = makeContainer();

      final state = await settledSession(container);

      expect(state.status, SessionStatus.unauthenticated);
      expect(auth.logoutCalls, 1);
    });
  });

  group('primer uso: negocio sin sucursales', () {
    setUp(() {
      branches.branches = [];
      auth.hasSession = true;
    });

    test('el MANAGER va a crear la primera sucursal y entra en ella', () async {
      auth.user = manager();
      final container = makeContainer();

      expect((await settledSession(container)).status, SessionStatus.needsFirstBranch);

      await container
          .read(sessionControllerProvider.notifier)
          .createFirstBranch(code: 'PRINCIPAL', name: 'Local principal');

      final state = container.read(sessionControllerProvider);
      expect(state.status, SessionStatus.ready);
      expect(state.branches.single.code, 'PRINCIPAL');
      expect(container.read(activeBranchProvider)!.name, 'Local principal');
    });

    test('si el backend rechaza la sucursal, sigue en la misma pantalla', () async {
      auth.user = manager();
      branches.createFailure = const Failure(code: 'branch_code_taken', message: 'Ya existe.');
      final container = makeContainer();
      await settledSession(container);

      await expectLater(
        container
            .read(sessionControllerProvider.notifier)
            .createFirstBranch(code: 'PRINCIPAL', name: 'Local'),
        throwsA(isA<Failure>()),
      );

      expect(container.read(sessionControllerProvider).status, SessionStatus.needsFirstBranch);
    });

    test('un SUPERVISOR solo ve el aviso: no puede crear sucursales', () async {
      auth.user = supervisor();
      final container = makeContainer();

      expect((await settledSession(container)).status, SessionStatus.branchUnavailable);
    });
  });

  group('login y logout', () {
    test('credenciales malas lanzan Failure y no cambian el estado', () async {
      auth.user = supervisor();
      final container = makeContainer();
      await settledSession(container);

      await expectLater(
        container
            .read(sessionControllerProvider.notifier)
            .login(username: 'caja1', password: 'mala'),
        throwsA(isA<Failure>().having((f) => f.code, 'code', 'authentication_failed')),
      );

      expect(container.read(sessionControllerProvider).status, SessionStatus.unauthenticated);
    });

    test('login correcto carga usuario y sucursal; logout lo borra todo', () async {
      auth.user = manager();
      preference.branchCode = 'VILLA_LIBERTAD';
      final container = makeContainer();
      await settledSession(container);

      final controller = container.read(sessionControllerProvider.notifier);
      await controller.login(username: 'jefe', password: 'secreta');

      expect(container.read(sessionControllerProvider).status, SessionStatus.ready);
      expect(container.read(currentUserProvider)!.username, 'jefe');
      expect(container.read(activeBranchProvider), villaLibertad);

      await controller.logout();

      expect(container.read(sessionControllerProvider).status, SessionStatus.unauthenticated);
      expect(container.read(currentUserProvider), isNull);
      expect(container.read(activeBranchProvider), isNull);
      expect(preference.branchCode, isNull);
      expect(auth.hasSession, isFalse);
    });

    test('cuando vence la sesión vuelve al login con un aviso', () async {
      auth
        ..hasSession = true
        ..user = supervisor();
      final container = makeContainer();
      await settledSession(container);

      container.read(sessionExpiredProvider.notifier).notify();

      final state = container.read(sessionControllerProvider);
      expect(state.status, SessionStatus.unauthenticated);
      expect(state.failure!.code, 'token_not_valid');
      expect(container.read(currentUserProvider), isNull);
    });
  });

  group('cambio de sucursal', () {
    test('un MANAGER con varias sedes puede volver al selector y cancelar', () async {
      auth
        ..hasSession = true
        ..user = manager();
      preference.branchCode = 'VILLA_LIBERTAD';
      final container = makeContainer();
      await settledSession(container);
      final controller = container.read(sessionControllerProvider.notifier);

      await controller.requestBranchChange();
      expect(container.read(sessionControllerProvider).status, SessionStatus.needsBranchSelection);

      controller.cancelBranchChange();
      expect(container.read(sessionControllerProvider).status, SessionStatus.ready);
      expect(container.read(activeBranchProvider), villaLibertad);
    });

    test('un SUPERVISOR no puede cambiar de sucursal', () async {
      auth
        ..hasSession = true
        ..user = supervisor();
      final container = makeContainer();
      await settledSession(container);

      await container.read(sessionControllerProvider.notifier).requestBranchChange();

      expect(container.read(sessionControllerProvider).status, SessionStatus.ready);
    });
  });
}
