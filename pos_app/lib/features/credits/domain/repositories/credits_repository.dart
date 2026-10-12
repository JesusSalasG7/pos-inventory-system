import 'package:pos_app/features/credits/domain/entities/credit.dart';
import 'package:pos_app/features/credits/domain/entities/credit_payment.dart';
import 'package:pos_app/features/credits/domain/entities/customer.dart';

/// Filtro del listado de deudas.
enum CreditStatus {
  /// Con saldo, vencidas o no.
  pending('PENDING'),

  /// Con saldo y el plazo vencido.
  overdue('OVERDUE'),

  /// Saldadas.
  paid('PAID');

  const CreditStatus(this.apiValue);
  final String apiValue;
}

/// Contrato de clientes a crédito, sus deudas y sus abonos. Los saldos son
/// los de la tienda indicada en `branchCode`.
abstract interface class CreditsRepository {
  /// Clientes por nombre. Con `withDebt` solo los que deben algo.
  Future<List<Customer>> fetchCustomers({
    required String branchCode,
    String search = '',
    bool onlyActive = false,
    bool withDebt = false,
  });

  Future<Customer> fetchCustomer(int customerId, {required String branchCode});

  /// Lanza `Failure` con `customer_tax_id_taken`, `invalid_customer_name`…
  Future<Customer> createCustomer(CustomerDraft draft, {required String branchCode});

  Future<Customer> updateCustomer(
    int customerId,
    CustomerDraft draft, {
    required String branchCode,
  });

  /// Deudas de la tienda, de la que vence antes a la que vence después.
  Future<List<Credit>> fetchCredits({
    required String branchCode,
    CreditStatus status = CreditStatus.pending,
    int? customerId,
  });

  /// Abonos del cliente en la tienda, del más reciente al más antiguo.
  Future<List<CreditPayment>> fetchPayments(int customerId, {required String branchCode});

  /// Cobra un abono en la caja abierta del usuario.
  ///
  /// Lanza `Failure` con `no_open_session`, `credit_overpayment`,
  /// `no_pending_credit`, `bcv_rate_unavailable`…
  Future<CreditPayment> registerPayment(int customerId, NewCreditPayment payment);
}
