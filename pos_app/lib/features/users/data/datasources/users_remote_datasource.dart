import 'package:dio/dio.dart';
import 'package:pos_app/core/network/paginated.dart';
import 'package:pos_app/features/auth/data/dtos/user_dto.dart';

class UsersRemoteDataSource {
  const UsersRemoteDataSource(this._dio);

  final Dio _dio;

  Future<Paginated<UserDto>> fetchUsers({required int page}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      'users/',
      queryParameters: {'page': page, 'page_size': Paginated.maxPageSize},
    );
    return Paginated.fromJson(response.data!, UserDto.fromJson);
  }

  Future<UserDto> createUser(Map<String, dynamic> body) async {
    final response = await _dio.post<Map<String, dynamic>>('users/', data: body);
    return UserDto.fromJson(response.data!);
  }

  Future<UserDto> updateUser(int userId, Map<String, dynamic> body) async {
    final response = await _dio.patch<Map<String, dynamic>>('users/$userId/', data: body);
    return UserDto.fromJson(response.data!);
  }
}
