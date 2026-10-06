import 'package:dio/dio.dart';
import 'package:pos_app/features/exchange_rate/data/dtos/exchange_rate_dto.dart';

class ExchangeRateRemoteDataSource {
  const ExchangeRateRemoteDataSource(this._dio);

  final Dio _dio;

  Future<ExchangeRateDto> fetchCurrent() async {
    final response = await _dio.get<Map<String, dynamic>>('exchange-rates/current/');
    return ExchangeRateDto.fromJson(response.data!);
  }
}
