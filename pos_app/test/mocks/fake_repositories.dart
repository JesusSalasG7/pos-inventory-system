import 'package:decimal/decimal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:pos_app/core/domain/app_user.dart';
import 'package:pos_app/core/domain/branch.dart';
import 'package:pos_app/core/domain/enums.dart';
import 'package:pos_app/core/errors/failure.dart';
import 'package:pos_app/core/network/api_exception.dart';
import 'package:pos_app/core/storage/branch_preference_storage.dart';
import 'package:pos_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:pos_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:pos_app/features/auth/presentation/providers/session_controller.dart';
import 'package:pos_app/features/branches/data/repositories/branch_repository_impl.dart';
import 'package:pos_app/features/branches/domain/repositories/branch_repository.dart';
import 'package:pos_app/features/exchange_rate/data/repositories/exchange_rate_repository_impl.dart';
import 'package:pos_app/features/exchange_rate/domain/repositories/exchange_rate_repository.dart';

const villaLibertad = Branch(code: 'VILLA_LIBERTAD', name: 'Villa Libertad');
const lasAmericas = Branch(code: 'LAS_AMERICAS', name: 'Las Américas');

AppUser manager({String? assignedBranch}) => AppUser(
  id: 1,
  username: 'jefe',
  fullName: 'Ana Gerente',
  role: UserRole.manager,
  assignedBranch: assignedBranch,
  isActive: true,
);

AppUser supervisor({String assignedBranch = 'VILLA_LIBERTAD'}) => AppUser(
  id: 2,
  username: 'caja1',
  fullName: 'Luis Supervisor',
  role: UserRole.supervisor,
  assignedBranch: assignedBranch,
  isActive: true,
);

const invalidCredentials = Failure(
  code: 'authentication_failed',
  message: 'Usuario o contraseña incorrectos, o la cuenta está inactiva.',
  type: ApiErrorType.api,
  statusCode: 401,
);

const offline = Failure(
  code: ApiException.noConnectionCode,
  message: 'No hay conexión con el servidor.',
  type: ApiErrorType.noConnection,
);

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.user, this.hasSession = false, this.validPassword = 'secreta'});

  AppUser? user;
  bool hasSession;
  String validPassword;

  /// Si se asigna, `fetchCurrentUser` falla con este error.
  Failure? fetchUserFailure;
  int loginCalls = 0;
  int logoutCalls = 0;

  @override
  Future<bool> hasStoredSession() async => hasSession;

  @override
  Future<void> login({required String username, required String password}) async {
    loginCalls++;
    if (password != validPassword) throw invalidCredentials;
    hasSession = true;
  }

  @override
  Future<AppUser> fetchCurrentUser() async {
    final failure = fetchUserFailure;
    if (failure != null) throw failure;
    return user!;
  }

  @override
  Future<void> logout() async {
    logoutCalls++;
    hasSession = false;
  }
}

class FakeBranchRepository implements BranchRepository {
  FakeBranchRepository([List<Branch> branches = const []]) : branches = [...branches];

  List<Branch> branches;
  Failure? createFailure;

  @override
  Future<List<Branch>> fetchActiveBranches() async => [...branches];

  @override
  Future<Branch> createBranch({required String code, required String name}) async {
    final failure = createFailure;
    if (failure != null) throw failure;
    final branch = Branch(code: code, name: name);
    branches.add(branch);
    return branch;
  }
}

class FakeExchangeRateRepository implements ExchangeRateRepository {
  FakeExchangeRateRepository([this.rate]);

  Decimal? rate;

  @override
  Future<Decimal?> fetchActiveRate() async => rate;
}

/// Overrides para montar la sesión con repositorios falsos.
List<Override> sessionOverrides({
  required FakeAuthRepository auth,
  required FakeBranchRepository branches,
  InMemoryBranchPreferenceStorage? preference,
  Decimal? rate,
}) => [
  authRepositoryProvider.overrideWithValue(auth),
  branchRepositoryProvider.overrideWithValue(branches),
  branchPreferenceStorageProvider.overrideWithValue(
    preference ?? InMemoryBranchPreferenceStorage(),
  ),
  exchangeRateRepositoryProvider.overrideWithValue(FakeExchangeRateRepository(rate)),
];

/// Espera a que el controlador termine de arrancar y devuelve su estado.
Future<SessionState> settledSession(ProviderContainer container) async {
  container.read(sessionControllerProvider);
  for (var i = 0; i < 50; i++) {
    await Future<void>.delayed(Duration.zero);
    final state = container.read(sessionControllerProvider);
    if (state.status != SessionStatus.loading) return state;
  }
  return container.read(sessionControllerProvider);
}
