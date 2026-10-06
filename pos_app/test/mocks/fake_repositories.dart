import 'package:decimal/decimal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:pos_app/core/domain/app_user.dart';
import 'package:pos_app/core/domain/branch.dart';
import 'package:pos_app/core/domain/enums.dart';
import 'package:pos_app/core/errors/failure.dart';
import 'package:pos_app/core/network/api_exception.dart';
import 'package:pos_app/core/network/paginated.dart';
import 'package:pos_app/core/storage/branch_preference_storage.dart';
import 'package:pos_app/core/storage/rate_notice_storage.dart';
import 'package:pos_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:pos_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:pos_app/features/auth/presentation/providers/session_controller.dart';
import 'package:pos_app/features/branches/data/repositories/branch_repository_impl.dart';
import 'package:pos_app/features/branches/domain/repositories/branch_repository.dart';
import 'package:pos_app/features/cash_session/data/repositories/cash_session_repository_impl.dart';
import 'package:pos_app/features/cash_session/domain/cash_count.dart';
import 'package:pos_app/features/cash_session/domain/entities/cash_session.dart';
import 'package:pos_app/features/cash_session/domain/repositories/cash_session_repository.dart';
import 'package:pos_app/features/exchange_rate/data/repositories/exchange_rate_repository_impl.dart';
import 'package:pos_app/features/exchange_rate/domain/entities/exchange_rate.dart';
import 'package:pos_app/features/exchange_rate/domain/repositories/exchange_rate_repository.dart';
import 'package:pos_app/features/exchange_rate/presentation/providers/rate_change_notice_provider.dart';
import 'package:pos_app/features/inventory/data/repositories/inventory_repository_impl.dart';
import 'package:pos_app/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:pos_app/features/sales/data/repositories/sales_repository_impl.dart';
import 'package:pos_app/features/sales/domain/entities/sales_summary.dart';
import 'package:pos_app/features/sales/domain/repositories/sales_repository.dart';

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

  BcvRate? bcv;
  final List<ExchangeRate> history = [];

  /// Tasa activa completa; por defecto una manual con el valor de [rate].
  ExchangeRate? active;

  /// Lo que devolverá la próxima sincronización con el BCV.
  ExchangeRate? nextBcvRate;

  @override
  Future<ExchangeRate?> fetchActive() async {
    final value = rate;
    if (active != null) return active;
    if (value == null) return null;
    return ExchangeRate(id: 1000, rate: value, createdAt: DateTime.utc(2026, 10, 6, 14));
  }

  @override
  Future<BcvSyncResult> syncWithBcv() async {
    final next = nextBcvRate;
    if (next == null) return BcvSyncResult(rate: (await fetchActive())!, changed: false);
    nextBcvRate = null;
    active = next;
    rate = next.rate;
    history.insert(0, next);
    return BcvSyncResult(rate: next, changed: true);
  }

  @override
  Future<Paginated<ExchangeRate>> fetchHistory({required int page}) async =>
      Paginated(count: history.length, results: [...history]);

  @override
  Future<ExchangeRate> registerRate(Decimal rate) async {
    final created = ExchangeRate(
      id: history.length + 1,
      rate: rate,
      createdBy: 1,
      createdAt: DateTime.utc(2026, 10, 6, 14),
    );
    history.insert(0, created);
    this.rate = rate;
    active = created;
    return created;
  }

  @override
  Future<BcvRate> fetchBcvRate() async {
    final value = bcv;
    if (value == null) {
      throw const Failure(code: 'bcv_rate_unavailable', message: 'BCV no disponible.');
    }
    return value;
  }
}

Decimal dec(String value) => Decimal.parse(value);

/// Caja en memoria que replica las reglas del backend que la app necesita.
class FakeCashSessionRepository implements CashSessionRepository {
  FakeCashSessionRepository({this.current, Decimal? rate}) : rate = rate ?? dec('100');

  CashSession? current;
  final List<CashSession> closed = [];
  final List<CashExpense> expenses = [];

  /// Tasa con la que se calcula la diferencia al cerrar.
  Decimal rate;
  Decimal cashSalesUsd = Decimal.zero;
  Decimal cashSalesVes = Decimal.zero;
  Failure? openFailure;
  Failure? closeFailure;
  int summaryCalls = 0;

  @override
  Future<CashSession?> fetchCurrent() async => current;

  @override
  Future<CashSession> open({required String branchCode, required Decimal openingFloat}) async {
    final failure = openFailure;
    if (failure != null) throw failure;
    return current = CashSession(
      id: closed.length + 1,
      userId: 1,
      branchCode: branchCode,
      openedAt: DateTime.utc(2026, 10, 6, 12),
      openingFloat: openingFloat,
    );
  }

  @override
  Future<Paginated<CashSession>> fetchSessions({
    required String branchCode,
    required int page,
  }) async {
    final all = [?current, ...closed].where((s) => s.branchCode == branchCode).toList();
    return Paginated(count: all.length, results: all);
  }

  @override
  Future<List<CashExpense>> fetchExpenses(int sessionId) async => [
    for (final expense in expenses)
      if (expense.cashSessionId == sessionId) expense,
  ];

  @override
  Future<CashExpense> registerExpense({
    required int sessionId,
    required String reason,
    required Decimal amount,
    required Currency currency,
  }) async {
    final expense = CashExpense(
      id: expenses.length + 1,
      cashSessionId: sessionId,
      reason: reason,
      amount: amount,
      currency: currency,
      createdBy: 1,
      createdAt: DateTime.utc(2026, 10, 6, 13),
    );
    expenses.add(expense);
    return expense;
  }

  Decimal _expenses(int sessionId, Currency currency) => expenses
      .where((e) => e.cashSessionId == sessionId && e.currency == currency)
      .fold(Decimal.zero, (sum, e) => sum + e.amount);

  @override
  Future<CashCountSummary> fetchSummary(int sessionId) async {
    summaryCalls++;
    final session = current?.id == sessionId
        ? current!
        : closed.firstWhere((s) => s.id == sessionId);
    final expensesUsd = _expenses(sessionId, Currency.usd);
    final expensesVes = _expenses(sessionId, Currency.ves);
    return CashCountSummary(
      openingFloat: session.openingFloat,
      cashSalesUsd: cashSalesUsd,
      cashSalesVes: cashSalesVes,
      electronicSalesUsd: Decimal.zero,
      electronicSalesVes: Decimal.zero,
      expensesUsd: expensesUsd,
      expensesVes: expensesVes,
      expectedCashUsd: session.openingFloat + cashSalesUsd - expensesUsd,
      expectedCashVes: cashSalesVes - expensesVes,
    );
  }

  @override
  Future<CashSession> close({
    required int sessionId,
    required Decimal countedAmountUsd,
    required Decimal countedAmountVes,
  }) async {
    final failure = closeFailure;
    if (failure != null) throw failure;
    final summary = await fetchSummary(sessionId);
    final session = current!;
    final result = CashSession(
      id: session.id,
      userId: session.userId,
      branchCode: session.branchCode,
      openedAt: session.openedAt,
      closedAt: DateTime.utc(2026, 10, 6, 22),
      openingFloat: session.openingFloat,
      countedAmountUsd: countedAmountUsd,
      countedAmountVes: countedAmountVes,
      differenceUsd: CashCount.differenceUsd(
        countedUsd: countedAmountUsd,
        countedVes: countedAmountVes,
        expectedUsd: summary.expectedCashUsd,
        expectedVes: summary.expectedCashVes,
        usdToVesRate: rate,
      ),
    );
    closed.insert(0, result);
    current = null;
    return result;
  }
}

class FakeSalesRepository implements SalesRepository {
  SalesSummary summary = SalesSummary(
    salesCount: 0,
    totalUsd: Decimal.zero,
    totalVes: Decimal.zero,
  );
  String? lastBranchCode;
  DateTime? lastDateFrom;

  @override
  Future<SalesSummary> fetchSummary({
    required String branchCode,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    lastBranchCode = branchCode;
    lastDateFrom = dateFrom;
    return summary;
  }
}

class FakeInventoryRepository implements InventoryRepository {
  int lowStock = 0;

  @override
  Future<int> fetchLowStockCount({required String branchCode}) async => lowStock;
}

/// Overrides para montar la sesión con repositorios falsos.
List<Override> sessionOverrides({
  required FakeAuthRepository auth,
  required FakeBranchRepository branches,
  InMemoryBranchPreferenceStorage? preference,
  Decimal? rate,
  FakeExchangeRateRepository? rates,
  FakeCashSessionRepository? cash,
  FakeSalesRepository? sales,
  FakeInventoryRepository? inventory,
  InMemoryRateNoticeStorage? rateNotice,
}) => [
  rateNoticeStorageProvider.overrideWithValue(rateNotice ?? InMemoryRateNoticeStorage()),
  cashSessionRepositoryProvider.overrideWithValue(cash ?? FakeCashSessionRepository()),
  salesRepositoryProvider.overrideWithValue(sales ?? FakeSalesRepository()),
  inventoryRepositoryProvider.overrideWithValue(inventory ?? FakeInventoryRepository()),
  authRepositoryProvider.overrideWithValue(auth),
  branchRepositoryProvider.overrideWithValue(branches),
  branchPreferenceStorageProvider.overrideWithValue(
    preference ?? InMemoryBranchPreferenceStorage(),
  ),
  exchangeRateRepositoryProvider.overrideWithValue(rates ?? FakeExchangeRateRepository(rate)),
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
