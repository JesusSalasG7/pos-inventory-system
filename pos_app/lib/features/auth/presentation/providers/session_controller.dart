import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:pos_app/core/domain/app_user.dart';
import 'package:pos_app/core/domain/branch.dart';
import 'package:pos_app/core/errors/error_messages.dart';
import 'package:pos_app/core/errors/failure.dart';
import 'package:pos_app/core/session/active_branch_provider.dart';
import 'package:pos_app/core/session/current_user_provider.dart';
import 'package:pos_app/core/session/session_expired_provider.dart';
import 'package:pos_app/core/storage/branch_preference_storage.dart';
import 'package:pos_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:pos_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:pos_app/features/branches/data/repositories/branch_repository_impl.dart';
import 'package:pos_app/features/branches/domain/repositories/branch_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'session_controller.g.dart';

/// En qué punto del arranque está la app. El router decide la pantalla con esto.
enum SessionStatus {
  /// Comprobando si hay una sesión guardada.
  loading,

  /// No se pudo cargar la sesión (p. ej. sin conexión). Se puede reintentar.
  error,
  unauthenticated,

  /// MANAGER en un negocio que todavía no tiene ninguna sucursal.
  needsFirstBranch,

  /// MANAGER con acceso a todas y varias sucursales activas: debe elegir una.
  needsBranchSelection,

  /// El usuario no puede operar: su sucursal está inactiva o no hay ninguna.
  branchUnavailable,
  ready,
}

@immutable
class SessionState {
  const SessionState({required this.status, this.branches = const [], this.failure});

  final SessionStatus status;

  /// Sucursales activas a las que el usuario puede cambiar.
  final List<Branch> branches;

  /// Motivo del estado `error`, o aviso para mostrar en el login.
  final Failure? failure;

  @override
  bool operator ==(Object other) =>
      other is SessionState &&
      other.status == status &&
      listEquals(other.branches, branches) &&
      other.failure == failure;

  @override
  int get hashCode => Object.hash(status, Object.hashAll(branches), failure);
}

@Riverpod(keepAlive: true)
BranchPreferenceStorage branchPreferenceStorage(Ref ref) => SecureBranchPreferenceStorage();

/// Orquesta el arranque de la sesión: tokens → usuario → sucursal activa.
///
/// El rol y la sucursal vienen de la cuenta; nunca se eligen en el login. La
/// sucursal se resuelve igual que en el backend (`resolve_branch`): la asignada
/// al usuario o, para un MANAGER con acceso a todas, la única activa o la que elija.
@Riverpod(keepAlive: true)
class SessionController extends _$SessionController {
  AuthRepository get _auth => ref.read(authRepositoryProvider);
  BranchRepository get _branches => ref.read(branchRepositoryProvider);
  BranchPreferenceStorage get _preference => ref.read(branchPreferenceStorageProvider);

  @override
  SessionState build() {
    ref.listen(sessionExpiredProvider, (previous, next) => _onSessionExpired());
    unawaited(Future.microtask(bootstrap));
    return const SessionState(status: SessionStatus.loading);
  }

  /// Restaura la sesión guardada, si la hay. También sirve para reintentar.
  Future<void> bootstrap() async {
    state = const SessionState(status: SessionStatus.loading);
    if (!await _auth.hasStoredSession()) {
      _clearSession();
      state = const SessionState(status: SessionStatus.unauthenticated);
      return;
    }
    await _loadSession();
  }

  /// Inicia sesión. Lanza `Failure` si las credenciales no valen, para que el
  /// login muestre el mensaje; el estado no cambia en ese caso.
  Future<void> login({required String username, required String password}) async {
    await _auth.login(username: username, password: password);
    state = const SessionState(status: SessionStatus.loading);
    await _loadSession();
  }

  Future<void> logout() async {
    await _auth.logout();
    await _preference.clear();
    _clearSession();
    state = const SessionState(status: SessionStatus.unauthenticated);
  }

  /// Fija la sucursal de trabajo de un MANAGER con varias sedes.
  Future<void> selectBranch(Branch branch) async {
    await _preference.save(branch.code);
    _activate(branch, state.branches);
  }

  /// Vuelve al selector para cambiar de sucursal, con la lista actualizada.
  Future<void> requestBranchChange() async {
    final user = ref.read(currentUserProvider);
    if (user == null || !user.hasAllBranchesAccess) return;
    var branches = state.branches;
    try {
      branches = await _branches.fetchActiveBranches();
    } on Failure {
      // Sin conexión se ofrece la lista que ya se conocía.
    }
    if (branches.length < 2) return;
    state = SessionState(status: SessionStatus.needsBranchSelection, branches: branches);
  }

  /// Cierra el selector sin cambiar de sucursal.
  void cancelBranchChange() {
    if (ref.read(activeBranchProvider) == null) return;
    state = SessionState(status: SessionStatus.ready, branches: state.branches);
  }

  /// Crea la primera sucursal del negocio y entra en ella. Lanza `Failure`
  /// si el backend la rechaza.
  Future<void> createFirstBranch({required String code, required String name}) async {
    final branch = await _branches.createBranch(code: code, name: name);
    _activate(branch, [branch]);
  }

  Future<void> _loadSession() async {
    try {
      final user = await _auth.fetchCurrentUser();
      ref.read(currentUserProvider.notifier).set(user);
      final branches = await _branches.fetchActiveBranches();
      await _resolveBranch(user, branches);
    } on Failure catch (failure) {
      if (failure.statusCode == 401) {
        // El refresh venció: no queda sesión que restaurar.
        await _auth.logout();
        _clearSession();
        state = const SessionState(status: SessionStatus.unauthenticated);
      } else {
        state = SessionState(status: SessionStatus.error, failure: failure);
      }
    }
  }

  Future<void> _resolveBranch(AppUser user, List<Branch> branches) async {
    final assigned = user.assignedBranch;
    if (assigned != null) {
      final branch = _find(branches, assigned);
      if (branch == null) {
        state = SessionState(status: SessionStatus.branchUnavailable, branches: branches);
      } else {
        _activate(branch, branches);
      }
      return;
    }
    if (!user.hasAllBranchesAccess) {
      state = SessionState(status: SessionStatus.branchUnavailable, branches: branches);
      return;
    }
    if (branches.isEmpty) {
      state = const SessionState(status: SessionStatus.needsFirstBranch);
      return;
    }
    if (branches.length == 1) {
      _activate(branches.single, branches);
      return;
    }
    final remembered = await _preference.read();
    final branch = remembered == null ? null : _find(branches, remembered);
    if (branch != null) {
      _activate(branch, branches);
    } else {
      state = SessionState(status: SessionStatus.needsBranchSelection, branches: branches);
    }
  }

  void _activate(Branch branch, List<Branch> branches) {
    ref.read(activeBranchProvider.notifier).select(branch);
    state = SessionState(status: SessionStatus.ready, branches: branches);
  }

  void _clearSession() {
    ref.read(currentUserProvider.notifier).clear();
    ref.read(activeBranchProvider.notifier).clear();
  }

  void _onSessionExpired() {
    if (state.status == SessionStatus.unauthenticated) return;
    _clearSession();
    state = SessionState(
      status: SessionStatus.unauthenticated,
      failure: Failure(
        code: 'token_not_valid',
        message: ErrorMessages.forCode('token_not_valid'),
        statusCode: 401,
      ),
    );
  }

  static Branch? _find(List<Branch> branches, String code) {
    for (final branch in branches) {
      if (branch.code == code) return branch;
    }
    return null;
  }
}
