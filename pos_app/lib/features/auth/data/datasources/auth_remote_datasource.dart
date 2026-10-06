import 'package:dio/dio.dart';
import 'package:pos_app/core/network/auth_interceptor.dart';
import 'package:pos_app/features/auth/data/dtos/token_pair_dto.dart';
import 'package:pos_app/features/auth/data/dtos/user_dto.dart';

class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._dio);

  final Dio _dio;

  Future<TokenPairDto> login({required String username, required String password}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      AuthInterceptor.loginPath,
      data: {'username': username, 'password': password},
    );
    return TokenPairDto.fromJson(response.data!);
  }

  Future<UserDto> fetchCurrentUser() async {
    final response = await _dio.get<Map<String, dynamic>>('auth/me/');
    return UserDto.fromJson(response.data!);
  }
}
