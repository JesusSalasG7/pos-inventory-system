import 'package:pos_app/core/session/active_branch_provider.dart';
import 'package:pos_app/features/cash_session/presentation/providers/current_session_provider.dart';
import 'package:pos_app/features/credits/data/repositories/credits_repository_impl.dart';
import 'package:pos_app/features/credits/domain/entities/credit.dart';
import 'package:pos_app/features/credits/domain/entities/credit_payment.dart';
import 'package:pos_app/features/credits/domain/entities/customer.dart';
import 'package:pos_app/features/credits/domain/repositories/credits_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'credits_providers.g.dart';

/// Clientes con lo que deben en la tienda activa. Con `withDebt` solo los
/// que deben; con `onlyActive`, solo a los que se les puede vender a crédito.
@riverpod
Future<List<Customer>> customers(
  Ref ref, {
  String search = '',
  bool withDebt = false,
  bool onlyActive = false,
}) async {
  final branch = ref.watch(activeBranchProvider);
  if (branch == null) return const [];
  return ref
      .watch(creditsRepositoryProvider)
      .fetchCustomers(
        branchCode: branch.code,
        search: search,
        withDebt: withDebt,
        onlyActive: onlyActive,
      );
}

/// Un cliente con su saldo en la tienda activa y la tasa del BCV del día.
@riverpod
Future<Customer> customer(Ref ref, int customerId) {
  final branch = ref.watch(activeBranchProvider)!;
  return ref.watch(creditsRepositoryProvider).fetchCustomer(customerId, branchCode: branch.code);
}

/// Compras a crédito de un cliente en la tienda activa, pendientes o pagadas.
@riverpod
Future<List<Credit>> customerCredits(Ref ref, int customerId, CreditStatus status) {
  final branch = ref.watch(activeBranchProvider)!;
  return ref
      .watch(creditsRepositoryProvider)
      .fetchCredits(branchCode: branch.code, status: status, customerId: customerId);
}

/// Abonos de un cliente en la tienda activa, del más reciente al más antiguo.
@riverpod
Future<List<CreditPayment>> customerPayments(Ref ref, int customerId) {
  final branch = ref.watch(activeBranchProvider)!;
  return ref.watch(creditsRepositoryProvider).fetchPayments(customerId, branchCode: branch.code);
}

/// Deudas con saldo de la tienda activa. Con ellas se programan los avisos
/// del teléfono y se arma la tarjeta de Inicio.
@riverpod
Future<List<Credit>> pendingCredits(Ref ref) async {
  final branch = ref.watch(activeBranchProvider);
  if (branch == null) return const [];
  return ref.watch(creditsRepositoryProvider).fetchCredits(branchCode: branch.code);
}

/// Altas, cambios y abonos de clientes. Tras cada operación invalida lo que
/// depende de ella (saldos, listas, avisos y la caja donde entró el abono).
///
/// `keepAlive`: ninguna pantalla lo escucha, solo lo leen al guardar. Si se
/// destruyera solo, lo haría a mitad de la petición y la pantalla quedaría
/// esperando para siempre aunque el backend ya hubiera guardado.
@Riverpod(keepAlive: true)
class CreditsController extends _$CreditsController {
  @override
  void build() {}

  /// Lanza `Failure`.
  Future<Customer> createCustomer(CustomerDraft draft) async {
    final branch = ref.read(activeBranchProvider)!;
    final customer = await ref
        .read(creditsRepositoryProvider)
        .createCustomer(draft, branchCode: branch.code);
    ref.invalidate(customersProvider);
    return customer;
  }

  /// Lanza `Failure`.
  Future<Customer> updateCustomer(int customerId, CustomerDraft draft) async {
    final branch = ref.read(activeBranchProvider)!;
    final customer = await ref
        .read(creditsRepositoryProvider)
        .updateCustomer(customerId, draft, branchCode: branch.code);
    ref
      ..invalidate(customersProvider)
      ..invalidate(customerProvider(customerId))
      ..invalidate(pendingCreditsProvider);
    return customer;
  }

  /// Cobra un abono en la caja abierta. Lanza `Failure`.
  Future<CreditPayment> registerPayment(int customerId, NewCreditPayment payment) async {
    final created = await ref.read(creditsRepositoryProvider).registerPayment(customerId, payment);
    debtsChanged(ref, customerId: customerId);
    final sessionId = ref.read(currentSessionProvider).value?.id;
    if (sessionId != null) {
      ref
        ..invalidate(sessionSummaryProvider(sessionId))
        ..invalidate(sessionSalesReportProvider(sessionId));
    }
    return created;
  }
}

/// Invalida todo lo que depende de las deudas: tras una venta a crédito o un abono.
void debtsChanged(Ref ref, {int? customerId}) {
  ref
    ..invalidate(customersProvider)
    ..invalidate(pendingCreditsProvider);
  if (customerId != null) {
    ref
      ..invalidate(customerProvider(customerId))
      ..invalidate(customerCreditsProvider(customerId, CreditStatus.pending))
      ..invalidate(customerCreditsProvider(customerId, CreditStatus.paid))
      ..invalidate(customerPaymentsProvider(customerId));
  }
}
