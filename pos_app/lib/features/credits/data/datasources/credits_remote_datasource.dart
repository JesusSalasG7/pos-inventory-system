import 'package:dio/dio.dart';
import 'package:pos_app/core/currency/money.dart';
import 'package:pos_app/core/network/paginated.dart';
import 'package:pos_app/features/credits/data/dtos/credit_dtos.dart';
import 'package:pos_app/features/credits/domain/entities/credit_payment.dart';
import 'package:pos_app/features/credits/domain/entities/customer.dart';

class CreditsRemoteDataSource {
  const CreditsRemoteDataSource(this._dio);

  final Dio _dio;

  Future<Paginated<CustomerDto>> fetchCustomers({
    required String branchCode,
    required int page,
    String search = '',
    bool onlyActive = false,
    bool withDebt = false,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      'customers/',
      queryParameters: {
        'branch': branchCode,
        'page': page,
        'page_size': Paginated.maxPageSize,
        if (search.trim().isNotEmpty) 'search': search.trim(),
        if (onlyActive) 'active': true,
        if (withDebt) 'with_debt': true,
      },
    );
    return Paginated.fromJson(response.data!, CustomerDto.fromJson);
  }

  Future<CustomerDto> fetchCustomer(int customerId, {required String branchCode}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      'customers/$customerId/',
      queryParameters: {'branch': branchCode},
    );
    return CustomerDto.fromJson(response.data!);
  }

  /// Cuerpo de `POST customers/` y `PATCH customers/<id>/`.
  static Map<String, dynamic> customerBody(CustomerDraft draft, {bool includeActive = false}) => {
    'name': draft.name.trim(),
    'tax_id': draft.taxId.trim(),
    'phone': draft.phone.trim(),
    'credit_days': draft.creditDays,
    if (includeActive) 'active': draft.active,
  };

  Future<CustomerDto> createCustomer(CustomerDraft draft, {required String branchCode}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      'customers/',
      data: customerBody(draft),
      queryParameters: {'branch': branchCode},
    );
    return CustomerDto.fromJson(response.data!);
  }

  Future<CustomerDto> updateCustomer(
    int customerId,
    CustomerDraft draft, {
    required String branchCode,
  }) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      'customers/$customerId/',
      data: customerBody(draft, includeActive: true),
      queryParameters: {'branch': branchCode},
    );
    return CustomerDto.fromJson(response.data!);
  }

  Future<Paginated<CreditDto>> fetchCredits({
    required String branchCode,
    required String status,
    required int page,
    int? customerId,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      'credits/',
      queryParameters: {
        'branch': branchCode,
        'status': status,
        'page': page,
        'page_size': Paginated.maxPageSize,
        'customer': ?customerId,
      },
    );
    return Paginated.fromJson(response.data!, CreditDto.fromJson);
  }

  Future<Paginated<CreditPaymentDto>> fetchPayments(
    int customerId, {
    required String branchCode,
    required int page,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      'customers/$customerId/payments/',
      queryParameters: {'branch': branchCode, 'page': page, 'page_size': Paginated.maxPageSize},
    );
    return Paginated.fromJson(response.data!, CreditPaymentDto.fromJson);
  }

  /// Cuerpo de `POST customers/<id>/payments/`. El monto va como string decimal.
  static Map<String, dynamic> paymentBody(NewCreditPayment payment) => {
    'method': payment.method.apiValue,
    'currency': payment.method.currency.apiValue,
    'amount': moneyToApi(payment.amount),
    if (payment.approvalReference.trim().isNotEmpty)
      'approval_reference': payment.approvalReference.trim(),
  };

  Future<CreditPaymentDto> registerPayment(int customerId, NewCreditPayment payment) async {
    final response = await _dio.post<Map<String, dynamic>>(
      'customers/$customerId/payments/',
      data: paymentBody(payment),
    );
    return CreditPaymentDto.fromJson(response.data!);
  }
}
