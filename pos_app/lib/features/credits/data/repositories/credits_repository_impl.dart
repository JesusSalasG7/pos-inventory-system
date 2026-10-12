import 'package:pos_app/core/errors/failure.dart';
import 'package:pos_app/core/network/api_client.dart';
import 'package:pos_app/core/network/paginated.dart';
import 'package:pos_app/features/credits/data/datasources/credits_remote_datasource.dart';
import 'package:pos_app/features/credits/domain/entities/credit.dart';
import 'package:pos_app/features/credits/domain/entities/credit_payment.dart';
import 'package:pos_app/features/credits/domain/entities/customer.dart';
import 'package:pos_app/features/credits/domain/repositories/credits_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'credits_repository_impl.g.dart';

@Riverpod(keepAlive: true)
CreditsRepository creditsRepository(Ref ref) {
  return CreditsRepositoryImpl(CreditsRemoteDataSource(ref.watch(dioProvider)));
}

class CreditsRepositoryImpl implements CreditsRepository {
  const CreditsRepositoryImpl(this._remote);

  final CreditsRemoteDataSource _remote;

  @override
  Future<List<Customer>> fetchCustomers({
    required String branchCode,
    String search = '',
    bool onlyActive = false,
    bool withDebt = false,
  }) {
    return Failure.guard(() async {
      final dtos = await Paginated.fetchAll(
        (page) => _remote.fetchCustomers(
          branchCode: branchCode,
          page: page,
          search: search,
          onlyActive: onlyActive,
          withDebt: withDebt,
        ),
      );
      return [for (final dto in dtos) dto.toEntity()];
    });
  }

  @override
  Future<Customer> fetchCustomer(int customerId, {required String branchCode}) {
    return Failure.guard(
      () async => (await _remote.fetchCustomer(customerId, branchCode: branchCode)).toEntity(),
    );
  }

  @override
  Future<Customer> createCustomer(CustomerDraft draft, {required String branchCode}) {
    return Failure.guard(
      () async => (await _remote.createCustomer(draft, branchCode: branchCode)).toEntity(),
    );
  }

  @override
  Future<Customer> updateCustomer(
    int customerId,
    CustomerDraft draft, {
    required String branchCode,
  }) {
    return Failure.guard(
      () async =>
          (await _remote.updateCustomer(customerId, draft, branchCode: branchCode)).toEntity(),
    );
  }

  @override
  Future<List<Credit>> fetchCredits({
    required String branchCode,
    CreditStatus status = CreditStatus.pending,
    int? customerId,
  }) {
    return Failure.guard(() async {
      final dtos = await Paginated.fetchAll(
        (page) => _remote.fetchCredits(
          branchCode: branchCode,
          status: status.apiValue,
          page: page,
          customerId: customerId,
        ),
      );
      return [for (final dto in dtos) dto.toEntity()];
    });
  }

  @override
  Future<List<CreditPayment>> fetchPayments(int customerId, {required String branchCode}) {
    return Failure.guard(() async {
      final dtos = await Paginated.fetchAll(
        (page) => _remote.fetchPayments(customerId, branchCode: branchCode, page: page),
      );
      return [for (final dto in dtos) dto.toEntity()];
    });
  }

  @override
  Future<CreditPayment> registerPayment(int customerId, NewCreditPayment payment) {
    return Failure.guard(
      () async => (await _remote.registerPayment(customerId, payment)).toEntity(),
    );
  }
}
