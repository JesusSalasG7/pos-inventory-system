import 'package:pos_app/core/domain/branch.dart';
import 'package:pos_app/core/errors/failure.dart';
import 'package:pos_app/core/network/api_client.dart';
import 'package:pos_app/core/network/paginated.dart';
import 'package:pos_app/features/branches/data/datasources/branch_remote_datasource.dart';
import 'package:pos_app/features/branches/domain/repositories/branch_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'branch_repository_impl.g.dart';

@Riverpod(keepAlive: true)
BranchRepository branchRepository(Ref ref) {
  return BranchRepositoryImpl(BranchRemoteDataSource(ref.watch(dioProvider)));
}

class BranchRepositoryImpl implements BranchRepository {
  const BranchRepositoryImpl(this._remote);

  final BranchRemoteDataSource _remote;

  @override
  Future<List<Branch>> fetchActiveBranches() {
    return Failure.guard(() async {
      final dtos = await Paginated.fetchAll(
        (page) => _remote.fetchBranches(page: page, onlyActive: true),
      );
      return [for (final dto in dtos) dto.toEntity()];
    });
  }

  @override
  Future<List<Branch>> fetchAllBranches() {
    return Failure.guard(() async {
      final dtos = await Paginated.fetchAll((page) => _remote.fetchBranches(page: page));
      return [for (final dto in dtos) dto.toEntity()];
    });
  }

  @override
  Future<Branch> updateBranch(String code, {String? name, bool? active}) {
    return Failure.guard(
      () async => (await _remote.updateBranch(code, name: name?.trim(), active: active)).toEntity(),
    );
  }

  @override
  Future<Branch> createBranch({required String code, required String name}) {
    return Failure.guard(
      () async => (await _remote.createBranch(code: code, name: name.trim())).toEntity(),
    );
  }
}
