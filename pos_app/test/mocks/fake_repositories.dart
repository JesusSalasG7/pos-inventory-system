import 'package:decimal/decimal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:pos_app/core/currency/currency_converter.dart';
import 'package:pos_app/core/currency/money.dart';
import 'package:pos_app/core/currency/ves_pricing.dart';
import 'package:pos_app/core/domain/app_user.dart';
import 'package:pos_app/core/domain/branch.dart';
import 'package:pos_app/core/domain/category.dart';
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
import 'package:pos_app/features/cash_session/domain/entities/session_sales_report.dart';
import 'package:pos_app/features/cash_session/domain/repositories/cash_session_repository.dart';
import 'package:pos_app/features/credits/data/debt_notifier.dart';
import 'package:pos_app/features/credits/data/repositories/credits_repository_impl.dart';
import 'package:pos_app/features/credits/domain/entities/credit.dart';
import 'package:pos_app/features/credits/domain/entities/credit_payment.dart';
import 'package:pos_app/features/credits/domain/entities/customer.dart';
import 'package:pos_app/features/credits/domain/repositories/credits_repository.dart';
import 'package:pos_app/features/credits/presentation/providers/credit_reminders_provider.dart';
import 'package:pos_app/features/exchange_rate/data/repositories/exchange_rate_repository_impl.dart';
import 'package:pos_app/features/exchange_rate/domain/entities/exchange_rate.dart';
import 'package:pos_app/features/exchange_rate/domain/entities/pricing_settings.dart';
import 'package:pos_app/features/exchange_rate/domain/repositories/exchange_rate_repository.dart';
import 'package:pos_app/features/exchange_rate/presentation/providers/rate_change_notice_provider.dart';
import 'package:pos_app/features/inventory/data/repositories/inventory_repository_impl.dart';
import 'package:pos_app/features/inventory/domain/entities/inventory_movement.dart';
import 'package:pos_app/features/inventory/domain/entities/product.dart';
import 'package:pos_app/features/inventory/domain/repositories/inventory_repository.dart';
import 'package:pos_app/features/sales/data/repositories/sales_repository_impl.dart';
import 'package:pos_app/features/sales/domain/entities/sale.dart';
import 'package:pos_app/features/sales/domain/entities/sales_summary.dart';
import 'package:pos_app/features/sales/domain/repositories/sales_repository.dart';
import 'package:pos_app/features/statistics/data/repositories/statistics_repository_impl.dart';
import 'package:pos_app/features/statistics/domain/entities/statistics.dart';
import 'package:pos_app/features/statistics/domain/repositories/statistics_repository.dart';
import 'package:pos_app/features/users/data/repositories/users_repository_impl.dart';
import 'package:pos_app/features/users/domain/repositories/users_repository.dart';

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

  /// Si se asigna, `updateBranch` falla con este error.
  Failure? updateFailure;

  @override
  Future<List<Branch>> fetchActiveBranches() async => [
    for (final branch in branches)
      if (branch.active) branch,
  ];

  @override
  Future<List<Branch>> fetchAllBranches() async => [...branches];

  @override
  Future<Branch> updateBranch(String code, {String? name, bool? active}) async {
    final failure = updateFailure;
    if (failure != null) throw failure;
    final index = branches.indexWhere((branch) => branch.code == code);
    final current = branches[index];
    return branches[index] = Branch(
      code: code,
      name: name ?? current.name,
      active: active ?? current.active,
    );
  }

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

  /// Modo de tasa y redondeo en bolívares del negocio.
  PricingSettings settings = const PricingSettings();

  /// Si se asigna, cambiar la configuración falla con este error.
  Failure? settingsFailure;

  @override
  Future<PricingSettings> fetchPricingSettings() async => settings;

  @override
  Future<PricingSettings> updatePricingSettings({RateMode? rateMode, bool? roundVesUp}) async {
    final failure = settingsFailure;
    if (failure != null) throw failure;
    // Al volver al BCV el backend activa su tasa de inmediato.
    final bcvRate = bcv;
    if (rateMode == RateMode.bcv && settings.rateMode != RateMode.bcv && bcvRate != null) {
      active = ExchangeRate(
        id: 2000,
        rate: bcvRate.rate,
        source: RateSource.bcv,
        createdAt: DateTime.utc(2026, 10, 6, 14),
      );
      rate = bcvRate.rate;
    }
    return settings = PricingSettings(
      rateMode: rateMode ?? settings.rateMode,
      roundVesUp: roundVesUp ?? settings.roundVesUp,
    );
  }

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

  /// Resumen de ventas que devuelve cualquier caja; por defecto, sin ventas.
  SessionSalesReport salesReport = SessionSalesReport(
    salesCount: 0,
    totalUsd: Decimal.zero,
    totalVes: Decimal.zero,
    costUsd: Decimal.zero,
    costVes: Decimal.zero,
    profitUsd: Decimal.zero,
    profitVes: Decimal.zero,
    payments: const [],
    products: const [],
  );
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
      creditCashUsd: Decimal.zero,
      creditCashVes: Decimal.zero,
      creditElectronicVes: Decimal.zero,
      expectedCashUsd: session.openingFloat + cashSalesUsd - expensesUsd,
      expectedCashVes: cashSalesVes - expensesVes,
    );
  }

  @override
  Future<SessionSalesReport> fetchSalesReport(int sessionId) async => salesReport;

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

const liquids = ProductCategory(id: 1, name: 'Líquidos');
const powders = ProductCategory(id: 2, name: 'Polvos');
const accessories = ProductCategory(id: 3, name: 'Accesorios');

Product product(
  int id,
  String name, {
  String price = '1.00',
  UnitOfMeasure unit = UnitOfMeasure.unit,
  ProductCategory category = liquids,
  bool active = true,
}) => Product(
  id: id,
  name: name,
  category: category,
  unit: unit,
  costPriceUsd: dec('0.50'),
  salePriceUsd: dec(price),
  active: active,
);

StockedProduct stocked(Product product, String stock, {String minimum = '0'}) =>
    StockedProduct(product: product, currentStock: dec(stock), minimumStock: dec(minimum));

class FakeSalesRepository implements SalesRepository {
  SalesSummary summary = SalesSummary(
    salesCount: 0,
    totalUsd: Decimal.zero,
    totalVes: Decimal.zero,
  );
  String? lastBranchCode;
  DateTime? lastDateFrom;

  /// Ventas registradas, de la más reciente a la más antigua.
  final List<Sale> sales = [];

  /// Tamaño de página del historial.
  int pageSize = 25;

  /// Precios "de la base de datos" con los que se calculan las ventas.
  final Map<int, Decimal> prices = {};

  /// Tasa que el backend congela en la venta.
  Decimal rate = Decimal.parse('150');

  /// El negocio redondea los bolívares hacia arriba.
  bool roundVesUp = false;
  Failure? saleFailure;
  final List<NewSale> createdSales = [];

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

  @override
  Future<Paginated<Sale>> fetchSales({
    required String branchCode,
    required int page,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    final matching = [
      for (final sale in sales)
        if (sale.branchCode == branchCode &&
            (dateFrom == null || !sale.createdAt.isBefore(dateFrom)) &&
            (dateTo == null || !sale.createdAt.isAfter(dateTo)))
          sale,
    ];
    final start = (page - 1) * pageSize;
    return Paginated(
      count: matching.length,
      results: matching.skip(start).take(pageSize).toList(),
      next: start + pageSize < matching.length ? 'next' : null,
    );
  }

  @override
  Future<Sale> createSale(NewSale sale) async {
    final failure = saleFailure;
    if (failure != null) throw failure;
    createdSales.add(sale);
    final details = [
      for (final (index, item) in sale.items.indexed)
        SaleDetail(
          id: index + 1,
          productId: item.productId,
          quantity: item.quantity,
          unitPriceUsd: prices[item.productId] ?? Decimal.one,
          subtotalUsd: quantizeMoney(item.quantity * (prices[item.productId] ?? Decimal.one)),
          subtotalVes: VesPricing.lineSubtotal(
            item.quantity,
            prices[item.productId] ?? Decimal.one,
            rate,
            roundUp: roundVesUp,
          ),
        ),
    ];
    final totalUsd = details.fold(Decimal.zero, (sum, detail) => sum + detail.subtotalUsd);
    final creditDays = sale.customerId == null ? null : (sale.creditDays ?? 7);
    final created = Sale(
      id: createdSales.length,
      customerId: sale.payments.any((p) => p.method == PaymentMethod.credit)
          ? sale.customerId
          : null,
      creditDueDate: sale.payments.any((p) => p.method == PaymentMethod.credit)
          ? DateTime(2026, 10, 6).add(Duration(days: creditDays ?? 7))
          : null,
      cashSessionId: 1,
      userId: 1,
      branchCode: sale.branchCode,
      customerTaxId: sale.customerTaxId,
      customerName: sale.customerName,
      exchangeRateAtInvoice: rate,
      totalUsd: totalUsd,
      totalVes: roundVesUp
          ? details.fold(Decimal.zero, (sum, detail) => sum + detail.subtotalVes)
          : CurrencyConverter.usdToVes(totalUsd, rate),
      createdAt: DateTime.utc(2026, 10, 6, 16),
      details: details,
      payments: [
        for (final (index, payment) in sale.payments.indexed)
          SalePayment(
            id: index + 1,
            method: payment.method,
            currency: payment.method.currency,
            amount: payment.amount,
            approvalReference: payment.approvalReference,
          ),
      ],
    );
    sales.insert(0, created);
    return created;
  }
}

class FakeUsersRepository implements UsersRepository {
  FakeUsersRepository([List<AppUser> users = const []]) : users = [...users];

  List<AppUser> users;

  /// Contraseñas asignadas, por id de usuario.
  final Map<int, String> passwords = {};
  Failure? writeFailure;

  @override
  Future<List<AppUser>> fetchUsers() async => [...users];

  @override
  Future<AppUser> createUser({
    required String username,
    required String password,
    required String fullName,
    required UserRole role,
    required String? assignedBranch,
  }) async {
    final failure = writeFailure;
    if (failure != null) throw failure;
    final user = AppUser(
      id: users.fold(0, (highest, u) => u.id > highest ? u.id : highest) + 1,
      username: username,
      fullName: fullName,
      role: role,
      assignedBranch: assignedBranch,
      isActive: true,
    );
    users.add(user);
    passwords[user.id] = password;
    return user;
  }

  @override
  Future<AppUser> updateUser(
    int userId, {
    required String fullName,
    required UserRole role,
    required String? assignedBranch,
    required bool isActive,
    String? password,
  }) async {
    final failure = writeFailure;
    if (failure != null) throw failure;
    final index = users.indexWhere((user) => user.id == userId);
    if (password != null) passwords[userId] = password;
    return users[index] = AppUser(
      id: userId,
      username: users[index].username,
      fullName: fullName,
      role: role,
      assignedBranch: assignedBranch,
      isActive: isActive,
    );
  }
}

/// Inventario en memoria que replica las reglas del backend que la app necesita.
class FakeInventoryRepository implements InventoryRepository {
  int lowStock = 0;
  List<ProductCategory> categories = [liquids, powders, accessories];
  List<ProductSubcategory> subcategories = [];
  List<Product> products = [];
  List<BranchStock> stock = [];
  int catalogCalls = 0;

  /// Kardex, del movimiento más reciente al más antiguo.
  final List<InventoryMovement> movements = [];

  /// Tamaño de página del Kardex.
  int pageSize = 25;

  /// Si se asigna, las operaciones de escritura fallan con este error.
  Failure? writeFailure;

  /// Carga el catálogo y su stock en una sucursal a partir de productos con stock.
  void seed(String branchCode, List<StockedProduct> items) {
    products = [for (final item in items) item.product];
    stock = [
      for (final item in items)
        BranchStock(
          productId: item.product.id,
          productName: item.product.name,
          branchCode: branchCode,
          currentStock: item.currentStock,
          minimumStock: item.minimumStock,
        ),
    ];
  }

  /// Añade el stock de los mismos productos en otra sucursal.
  void seedStock(String branchCode, Map<int, String> stockByProduct) {
    stock.addAll([
      for (final MapEntry(key: productId, value: amount) in stockByProduct.entries)
        BranchStock(
          productId: productId,
          productName: products.firstWhere((p) => p.id == productId).name,
          branchCode: branchCode,
          currentStock: dec(amount),
          minimumStock: Decimal.zero,
        ),
    ]);
  }

  BranchStock? stockOf(String branchCode, int productId) =>
      stock.where((row) => row.branchCode == branchCode && row.productId == productId).firstOrNull;

  void _failIfRequested() {
    final failure = writeFailure;
    if (failure != null) throw failure;
  }

  void _putStock(String branchCode, int productId, {Decimal? current, Decimal? minimum}) {
    final previous = stockOf(branchCode, productId);
    stock
      ..removeWhere((row) => row.branchCode == branchCode && row.productId == productId)
      ..add(
        BranchStock(
          productId: productId,
          productName: products.firstWhere((p) => p.id == productId).name,
          branchCode: branchCode,
          currentStock: current ?? previous?.currentStock ?? Decimal.zero,
          minimumStock: minimum ?? previous?.minimumStock ?? Decimal.zero,
        ),
      );
  }

  Product _replace(int productId, Product Function(Product current) change) {
    final index = products.indexWhere((p) => p.id == productId);
    return products[index] = change(products[index]);
  }

  ProductCategory _category(int categoryId) =>
      categories.firstWhere((category) => category.id == categoryId);

  @override
  Future<List<ProductCategory>> fetchCategories() async =>
      [...categories]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

  @override
  Future<ProductCategory> createCategory(String name, {String icon = ''}) async {
    _failIfRequested();
    if (categories.any((c) => c.name.toLowerCase() == name.trim().toLowerCase())) {
      throw const Failure(
        code: 'category_name_taken',
        message: 'Ya existe una categoría con ese nombre.',
        type: ApiErrorType.api,
        statusCode: 409,
      );
    }
    final created = ProductCategory(
      id: categories.fold(0, (highest, c) => c.id > highest ? c.id : highest) + 1,
      name: name.trim(),
      icon: icon,
    );
    categories.add(created);
    return created;
  }

  @override
  Future<ProductCategory> updateCategory(
    int categoryId, {
    String? name,
    String? icon,
    bool? active,
  }) async {
    _failIfRequested();
    final index = categories.indexWhere((category) => category.id == categoryId);
    final current = categories[index];
    final updated = ProductCategory(
      id: current.id,
      name: name?.trim() ?? current.name,
      icon: icon ?? current.icon,
      active: active ?? current.active,
    );
    categories[index] = updated;
    // Los productos devuelven el nombre de su categoría.
    products = [
      for (final p in products)
        p.category.id == categoryId
            ? Product(
                id: p.id,
                name: p.name,
                category: ProductCategory(id: updated.id, name: updated.name, icon: updated.icon),
                subcategory: p.subcategory,
                unit: p.unit,
                costPriceUsd: p.costPriceUsd,
                salePriceUsd: p.salePriceUsd,
                active: p.active,
              )
            : p,
    ];
    return updated;
  }

  ProductSubcategory? _subcategory(int? subcategoryId) => subcategoryId == null
      ? null
      : subcategories.firstWhere((subcategory) => subcategory.id == subcategoryId);

  @override
  Future<List<ProductSubcategory>> fetchSubcategories() async =>
      [...subcategories]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

  @override
  Future<ProductSubcategory> createSubcategory({
    required int categoryId,
    required String name,
  }) async {
    _failIfRequested();
    final taken = subcategories.any(
      (s) => s.categoryId == categoryId && s.name.toLowerCase() == name.trim().toLowerCase(),
    );
    if (taken) {
      throw const Failure(
        code: 'subcategory_name_taken',
        message: 'La categoría ya tiene una subcategoría con ese nombre.',
        type: ApiErrorType.api,
        statusCode: 409,
      );
    }
    final created = ProductSubcategory(
      id: subcategories.fold(0, (highest, s) => s.id > highest ? s.id : highest) + 1,
      categoryId: categoryId,
      name: name.trim(),
    );
    subcategories.add(created);
    return created;
  }

  @override
  Future<ProductSubcategory> updateSubcategory(
    int subcategoryId, {
    String? name,
    bool? active,
  }) async {
    _failIfRequested();
    final index = subcategories.indexWhere((subcategory) => subcategory.id == subcategoryId);
    final current = subcategories[index];
    return subcategories[index] = ProductSubcategory(
      id: current.id,
      categoryId: current.categoryId,
      name: name?.trim() ?? current.name,
      active: active ?? current.active,
    );
  }

  @override
  Future<int> fetchLowStockCount({required String branchCode}) async => lowStock;

  @override
  Future<List<Product>> fetchProducts({bool onlyActive = false}) async {
    catalogCalls++;
    return [
      for (final product in products)
        if (!onlyActive || product.active) product,
    ];
  }

  @override
  Future<List<BranchStock>> fetchBranchStock({required String branchCode}) async => [
    for (final row in stock)
      if (row.branchCode == branchCode) row,
  ];

  @override
  Future<Product> createProduct(ProductDraft draft) async {
    _failIfRequested();
    final created = Product(
      id: products.fold(0, (highest, p) => p.id > highest ? p.id : highest) + 1,
      name: draft.name,
      category: _category(draft.categoryId),
      subcategory: _subcategory(draft.subcategoryId),
      unit: draft.unit,
      costPriceUsd: draft.costPriceUsd,
      salePriceUsd: draft.salePriceUsd,
      active: true,
    );
    products.add(created);
    return created;
  }

  @override
  Future<Product> updateProduct(int productId, ProductDraft draft) async {
    _failIfRequested();
    return _replace(
      productId,
      (current) => Product(
        id: current.id,
        name: draft.name,
        category: _category(draft.categoryId),
        subcategory: _subcategory(draft.subcategoryId),
        unit: draft.unit,
        costPriceUsd: draft.costPriceUsd,
        salePriceUsd: draft.salePriceUsd,
        active: current.active,
      ),
    );
  }

  @override
  Future<Product> toggleProductActive(int productId) async {
    _failIfRequested();
    return _replace(
      productId,
      (current) => Product(
        id: current.id,
        name: current.name,
        category: current.category,
        subcategory: current.subcategory,
        unit: current.unit,
        costPriceUsd: current.costPriceUsd,
        salePriceUsd: current.salePriceUsd,
        active: !current.active,
      ),
    );
  }

  @override
  Future<BranchStock> setMinimumStock({
    required String branchCode,
    required int productId,
    required Decimal minimumStock,
  }) async {
    _failIfRequested();
    _putStock(branchCode, productId, minimum: minimumStock);
    return stockOf(branchCode, productId)!;
  }

  @override
  Future<Paginated<InventoryMovement>> fetchMovements({
    required String branchCode,
    required int page,
    int? productId,
    MovementType? type,
  }) async {
    final matching = [
      for (final movement in movements)
        if (movement.branchCode == branchCode &&
            (productId == null || movement.productId == productId) &&
            (type == null || movement.type == type))
          movement,
    ];
    final start = (page - 1) * pageSize;
    final results = matching.skip(start).take(pageSize).toList();
    return Paginated(
      count: matching.length,
      results: results,
      next: start + pageSize < matching.length ? 'next' : null,
    );
  }

  @override
  Future<InventoryMovement?> registerMovement({
    required String branchCode,
    required int productId,
    required MovementType type,
    required Decimal quantity,
    String notes = '',
  }) async {
    _failIfRequested();
    final before = stockOf(branchCode, productId)?.currentStock ?? Decimal.zero;
    if (type == MovementType.waste && quantity > before) {
      throw const Failure(
        code: 'insufficient_stock',
        message: 'No hay stock suficiente para completar la operación.',
        type: ApiErrorType.api,
        statusCode: 422,
      );
    }
    final after = switch (type) {
      MovementType.entry => before + quantity,
      MovementType.waste || MovementType.sale => before - quantity,
      MovementType.adjustment => quantity,
    };
    if (type == MovementType.adjustment && after == before) return null;
    _putStock(branchCode, productId, current: after);
    final movement = InventoryMovement(
      id: movements.length + 1,
      productId: productId,
      branchCode: branchCode,
      type: type,
      quantity: (after - before).abs(),
      stockBefore: before,
      stockAfter: after,
      userId: 1,
      notes: notes,
      createdAt: DateTime.utc(2026, 10, 6, 15, movements.length),
    );
    movements.insert(0, movement);
    return movement;
  }
}

Customer customer(
  int id,
  String name, {
  String balance = '0',
  String overdue = '0',
  String? rate = '150',
  int creditDays = 7,
  bool active = true,
}) {
  final balanceUsd = dec(balance);
  final paymentRate = rate == null ? null : dec(rate);
  return Customer(
    id: id,
    name: name,
    taxId: 'V-$id',
    phone: '',
    creditDays: creditDays,
    active: active,
    balanceUsd: balanceUsd,
    overdueUsd: dec(overdue),
    openCredits: balanceUsd > Decimal.zero ? 1 : 0,
    nextDueDate: balanceUsd > Decimal.zero ? DateTime(2026, 10, 13) : null,
    balanceVes: paymentRate == null ? null : CurrencyConverter.usdToVes(balanceUsd, paymentRate),
    paymentRate: paymentRate,
  );
}

Credit credit(
  int id,
  Customer customer, {
  required String balance,
  required DateTime dueDate,
  bool overdue = false,
}) => Credit(
  id: id,
  saleId: id,
  customerId: customer.id,
  customerName: customer.name,
  customerPhone: customer.phone,
  branchCode: 'VILLA_LIBERTAD',
  amountUsd: dec(balance),
  balanceUsd: dec(balance),
  dueDate: dueDate,
  isOverdue: overdue,
  createdAt: DateTime.utc(2026, 10, 1, 15),
);

class FakeCreditsRepository implements CreditsRepository {
  final List<Customer> customers = [];
  final List<Credit> credits = [];
  final List<(int, NewCreditPayment)> registeredPayments = [];
  Failure? paymentFailure;

  /// Demora de las escrituras, para simular la red.
  Duration delay = Duration.zero;

  @override
  Future<List<Customer>> fetchCustomers({
    required String branchCode,
    String search = '',
    bool onlyActive = false,
    bool withDebt = false,
  }) async => [
    for (final c in customers)
      if ((!onlyActive || c.active) &&
          (!withDebt || c.hasDebt) &&
          c.name.toLowerCase().contains(search.toLowerCase()))
        c,
  ];

  @override
  Future<Customer> fetchCustomer(int customerId, {required String branchCode}) async =>
      customers.firstWhere((c) => c.id == customerId);

  @override
  Future<Customer> createCustomer(CustomerDraft draft, {required String branchCode}) async {
    if (delay > Duration.zero) await Future<void>.delayed(delay);
    final created = customer(customers.length + 1, draft.name, creditDays: draft.creditDays);
    customers.add(created);
    return created;
  }

  @override
  Future<Customer> updateCustomer(
    int customerId,
    CustomerDraft draft, {
    required String branchCode,
  }) async => customers.firstWhere((c) => c.id == customerId);

  @override
  Future<List<Credit>> fetchCredits({
    required String branchCode,
    CreditStatus status = CreditStatus.pending,
    int? customerId,
  }) async => [
    for (final c in credits)
      if ((customerId == null || c.customerId == customerId) &&
          switch (status) {
            CreditStatus.pending => !c.isPaid,
            CreditStatus.overdue => c.isOverdue,
            CreditStatus.paid => c.isPaid,
          })
        c,
  ];

  @override
  Future<List<CreditPayment>> fetchPayments(int customerId, {required String branchCode}) async =>
      const [];

  @override
  Future<CreditPayment> registerPayment(int customerId, NewCreditPayment payment) async {
    if (delay > Duration.zero) await Future<void>.delayed(delay);
    final failure = paymentFailure;
    if (failure != null) throw failure;
    registeredPayments.add((customerId, payment));
    final rate = customers.firstWhere((c) => c.id == customerId).paymentRate ?? Decimal.one;
    return CreditPayment(
      id: registeredPayments.length,
      customerId: customerId,
      method: payment.method,
      currency: payment.method.currency,
      amount: payment.amount,
      approvalReference: payment.approvalReference,
      usdToVesRate: rate,
      amountUsd: payment.method.currency == Currency.usd
          ? payment.amount
          : CurrencyConverter.vesToUsd(payment.amount, rate),
      createdAt: DateTime.utc(2026, 10, 6, 17),
    );
  }
}

/// Overrides para montar la sesión con repositorios falsos.
/// Estadísticas de ejemplo: dos categorías con ventas y, dentro de Líquidos,
/// una subcategoría y productos sin subcategoría.
class FakeStatisticsRepository implements StatisticsRepository {
  /// Filtros recibidos por cada sección, en orden de llegada.
  final List<StatsFilter> summaryCalls = [];
  final List<StatsFilter> groupCalls = [];
  final List<RankingOrder> rankingCalls = [];
  final List<StatsFilter> matrixCalls = [];
  final List<int?> healthCalls = [];

  /// Con `true` el período no tiene ventas.
  bool empty = false;

  /// Si se asignan, esa sección falla con el error.
  Failure? summaryFailure;
  Failure? matrixFailure;

  static StatsKpis _kpis(String revenue, String profit, String margin, int sales) => StatsKpis(
    revenue: dec(revenue),
    profit: dec(profit),
    margin: dec(margin),
    units: dec('33'),
    salesCount: sales,
    averageTicket: sales == 0 ? Decimal.zero : dec('26.00'),
  );

  @override
  Future<StatsSummary> fetchSummary({
    required String branchCode,
    required StatsFilter filter,
  }) async {
    summaryCalls.add(filter);
    final failure = summaryFailure;
    if (failure != null) throw failure;
    return StatsSummary(
      period: filter.period,
      previousPeriod: filter.period,
      current: empty ? _kpis('0', '0', '0', 0) : _kpis('52.00', '14.00', '26.92', 2),
      previous: empty ? _kpis('0', '0', '0', 0) : _kpis('10.00', '5.00', '50.00', 1),
      change: empty
          ? const StatsKpiChanges()
          : StatsKpiChanges(
              revenue: dec('420.00'),
              profit: dec('180.00'),
              margin: dec('-23.08'),
              units: dec('560.00'),
              salesCount: dec('100.00'),
            ),
    );
  }

  /// Con `false` no hubo ventas a crédito en el período.
  bool hasCreditSales = true;
  final List<StatsFilter> creditCalls = [];

  @override
  Future<CreditBreakdown> fetchCreditBreakdown({
    required String branchCode,
    required StatsFilter filter,
  }) async {
    creditCalls.add(filter);
    if (!hasCreditSales) {
      return CreditBreakdown(
        cash: SplitTotals(revenue: dec('52.00'), profit: dec('14.00'), margin: dec('26.92')),
        credit: SplitTotals(revenue: Decimal.zero, profit: Decimal.zero, margin: Decimal.zero),
        pendingRevenue: Decimal.zero,
        pendingProfit: Decimal.zero,
        creditShare: Decimal.zero,
      );
    }
    return CreditBreakdown(
      cash: SplitTotals(revenue: dec('42.00'), profit: dec('10.40'), margin: dec('24.76')),
      credit: SplitTotals(revenue: dec('10.00'), profit: dec('3.60'), margin: dec('36.00')),
      pendingRevenue: dec('4.00'),
      pendingProfit: dec('1.44'),
      creditShare: dec('19.23'),
    );
  }

  static GroupPerformance _group(int? id, String name, String revenue, String profit) =>
      GroupPerformance(
        id: id,
        name: name,
        units: dec('10'),
        revenue: dec(revenue),
        profit: dec(profit),
        margin: dec('31.91'),
      );

  @override
  Future<GroupReport> fetchGroups({required String branchCode, required StatsFilter filter}) async {
    groupCalls.add(filter);
    if (empty) return const GroupReport(level: GroupLevel.category, groups: []);
    if (filter.category == null) {
      return GroupReport(
        level: GroupLevel.category,
        groups: [_group(1, 'Líquidos', '47.00', '15.00'), _group(2, 'Polvos', '5.00', '-1.00')],
      );
    }
    return GroupReport(
      level: GroupLevel.subcategory,
      groups: [
        _group(7, 'Detergentes', '20.00', '10.00'),
        _group(null, 'Sin subcategoría', '27.00', '5.00'),
      ],
    );
  }

  static ProductPerformance _ranked(int id, String name, String units, String profit) =>
      ProductPerformance(
        productId: id,
        name: name,
        unit: UnitOfMeasure.liter,
        categoryName: 'Líquidos',
        subcategoryName: id == 1 ? 'Detergentes' : null,
        units: dec(units),
        revenue: dec('20.00'),
        profit: dec(profit),
        margin: dec('50.00'),
      );

  @override
  Future<List<ProductPerformance>> fetchRanking({
    required String branchCode,
    required StatsFilter filter,
    required RankingOrder order,
    int limit = 10,
  }) async {
    rankingCalls.add(order);
    if (empty) return const [];
    final detergent = _ranked(1, 'Detergente', '10', '10.00');
    final chlorine = _ranked(2, 'Cloro', '20', '4.00');
    return order == RankingOrder.units ? [chlorine, detergent] : [detergent, chlorine];
  }

  static MatrixPoint _point(int id, String name, String units, String margin, Quadrant quadrant) =>
      MatrixPoint(
        productId: id,
        name: name,
        unit: UnitOfMeasure.liter,
        units: dec(units),
        revenue: dec('20.00'),
        profit: dec('4.00'),
        margin: dec(margin),
        quadrant: quadrant,
      );

  @override
  Future<StatsMatrix> fetchMatrix({required String branchCode, required StatsFilter filter}) async {
    matrixCalls.add(filter);
    final failure = matrixFailure;
    if (failure != null) throw failure;
    return StatsMatrix(
      medianUnits: dec('6'),
      medianMargin: dec('25'),
      products: empty
          ? const []
          : [
              _point(1, 'Detergente', '10', '50.00', Quadrant.star),
              _point(2, 'Cloro', '20', '16.67', Quadrant.volumeDriver),
              // Un margen negativo también se pinta.
              _point(4, 'Ambientador', '2', '-20.00', Quadrant.review),
            ],
    );
  }

  @override
  Future<InventoryHealth> fetchInventoryHealth({
    required String branchCode,
    int? categoryId,
  }) async {
    healthCalls.add(categoryId);
    return InventoryHealth(
      immobilizedCapitalTotal: dec('12.00'),
      noMovement: [
        NoMovementItem(
          productId: 5,
          name: 'Viejo',
          unit: UnitOfMeasure.unit,
          stock: dec('4'),
          lastSaleDate: DateTime(2026, 3),
          immobilizedCapital: dec('10.00'),
        ),
        NoMovementItem(
          productId: 6,
          name: 'Nuevo',
          unit: UnitOfMeasure.unit,
          stock: dec('2'),
          immobilizedCapital: dec('2.00'),
        ),
      ],
      runningOut: [
        RunningOutItem(
          productId: 1,
          name: 'Detergente',
          unit: UnitOfMeasure.liter,
          stock: dec('3'),
          daysLeft: dec('9.0'),
        ),
      ],
    );
  }
}

List<Override> sessionOverrides({
  required FakeAuthRepository auth,
  required FakeBranchRepository branches,
  InMemoryBranchPreferenceStorage? preference,
  Decimal? rate,
  FakeExchangeRateRepository? rates,
  FakeCashSessionRepository? cash,
  FakeSalesRepository? sales,
  FakeInventoryRepository? inventory,
  FakeUsersRepository? users,
  InMemoryRateNoticeStorage? rateNotice,
  FakeCreditsRepository? credits,
  InMemoryDebtNotifier? debtNotifier,
  FakeStatisticsRepository? statistics,
}) => [
  statisticsRepositoryProvider.overrideWithValue(statistics ?? FakeStatisticsRepository()),
  rateNoticeStorageProvider.overrideWithValue(rateNotice ?? InMemoryRateNoticeStorage()),
  creditsRepositoryProvider.overrideWithValue(credits ?? FakeCreditsRepository()),
  debtNotificationsProvider.overrideWithValue(debtNotifier ?? InMemoryDebtNotifier()),
  cashSessionRepositoryProvider.overrideWithValue(cash ?? FakeCashSessionRepository()),
  salesRepositoryProvider.overrideWithValue(sales ?? FakeSalesRepository()),
  inventoryRepositoryProvider.overrideWithValue(inventory ?? FakeInventoryRepository()),
  usersRepositoryProvider.overrideWithValue(users ?? FakeUsersRepository()),
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
