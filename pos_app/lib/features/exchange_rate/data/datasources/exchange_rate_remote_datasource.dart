import 'package:decimal/decimal.dart';
import 'package:dio/dio.dart';
import 'package:pos_app/core/currency/money.dart';
import 'package:pos_app/core/network/paginated.dart';
import 'package:pos_app/features/exchange_rate/data/dtos/exchange_rate_dto.dart';

class ExchangeRateRemoteDataSource {
  const ExchangeRateRemoteDataSource(this._dio);

  final Dio _dio;

  Future<ExchangeRateDto> fetchCurrent() async {
    final response = await _dio.get<Map<String, dynamic>>('exchange-rates/current/');
    return ExchangeRateDto.fromJson(response.data!);
  }

  Future<Paginated<ExchangeRateDto>> fetchHistory({required int page}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      'exchange-rates/',
      queryParameters: {'page': page},
    );
    return Paginated.fromJson(response.data!, ExchangeRateDto.fromJson);
  }

  Future<ExchangeRateDto> register(Decimal rate) async {
    final response = await _dio.post<Map<String, dynamic>>(
      'exchange-rates/',
      data: {'usd_to_ves_rate': rateToApi(rate)},
    );
    return ExchangeRateDto.fromJson(response.data!);
  }

  Future<BcvRateDto> fetchBcv() async {
    final response = await _dio.get<Map<String, dynamic>>('exchange-rates/bcv/');
    return BcvRateDto.fromJson(response.data!);
  }
}
