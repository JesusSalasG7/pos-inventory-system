import 'package:dio/dio.dart';
import 'package:pos_app/core/network/paginated.dart';
import 'package:pos_app/features/branches/data/dtos/branch_dto.dart';

class BranchRemoteDataSource {
  const BranchRemoteDataSource(this._dio);

  final Dio _dio;

  Future<Paginated<BranchDto>> fetchBranches({required int page, bool onlyActive = false}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      'branches/',
      queryParameters: {
        'page': page,
        'page_size': Paginated.maxPageSize,
        if (onlyActive) 'active': 'true',
      },
    );
    return Paginated.fromJson(response.data!, BranchDto.fromJson);
  }

  Future<BranchDto> createBranch({required String code, required String name}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      'branches/',
      data: {'code': code, 'name': name},
    );
    return BranchDto.fromJson(response.data!);
  }
}
