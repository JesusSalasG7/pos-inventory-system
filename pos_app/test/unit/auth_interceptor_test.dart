import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/network/auth_interceptor.dart';
import 'package:pos_app/core/storage/token_storage.dart';

import '../mocks/fake_http_adapter.dart';

const unauthorized = FakeResponse(401, {
  'code': 'token_not_valid',
  'detail': 'Token is invalid',
  'meta': <String, dynamic>{},
});

class Harness {
  Harness({required this.storage, required bool refreshSucceeds}) {
    final options = BaseOptions(baseUrl: 'http://test/api/v1/');
    refreshAdapter = FakeHttpAdapter((request) async {
      // Simula latencia para que las peticiones concurrentes coincidan.
      await Future<void>.delayed(const Duration(milliseconds: 20));
      return refreshSucceeds ? const FakeResponse(200, {'access': 'new-access'}) : unauthorized;
    });
    apiAdapter = FakeHttpAdapter((request) {
      final token = request.headers['Authorization'];
      return token == 'Bearer new-access' ? const FakeResponse(200, {'ok': true}) : unauthorized;
    });
    final refreshDio = Dio(options)..httpClientAdapter = refreshAdapter;
    dio = Dio(options)..httpClientAdapter = apiAdapter;
    dio.interceptors.add(
      AuthInterceptor(
        tokenStorage: storage,
        refreshDio: refreshDio,
        retryDio: dio,
        onSessionExpired: () => sessionExpiredCalls++,
      ),
    );
  }

  final InMemoryTokenStorage storage;
  late final FakeHttpAdapter refreshAdapter;
  late final FakeHttpAdapter apiAdapter;
  late final Dio dio;
  int sessionExpiredCalls = 0;
}

void main() {
  test('agrega el token Bearer, salvo en login y refresh', () async {
    final harness = Harness(
      storage: InMemoryTokenStorage(access: 'new-access', refresh: 'refresh'),
      refreshSucceeds: true,
    );

    await harness.dio.get<dynamic>('products/');
    await harness.dio
        .post<dynamic>('auth/login/')
        .catchError((Object _) => Response<dynamic>(requestOptions: RequestOptions()));

    expect(harness.apiAdapter.requests[0].headers['Authorization'], 'Bearer new-access');
    expect(harness.apiAdapter.requests[1].headers.containsKey('Authorization'), isFalse);
  });

  test('ante un 401 refresca y reintenta una sola vez', () async {
    final harness = Harness(
      storage: InMemoryTokenStorage(access: 'expired', refresh: 'refresh'),
      refreshSucceeds: true,
    );

    final response = await harness.dio.get<dynamic>('products/');

    expect(response.statusCode, 200);
    expect(harness.refreshAdapter.countFor('auth/refresh/'), 1);
    expect(harness.apiAdapter.countFor('products/'), 2);
    expect(harness.storage.access, 'new-access');
    expect(harness.storage.refresh, 'refresh');
    expect(harness.sessionExpiredCalls, 0);
  });

  test('peticiones concurrentes comparten un único refresco', () async {
    final harness = Harness(
      storage: InMemoryTokenStorage(access: 'expired', refresh: 'refresh'),
      refreshSucceeds: true,
    );

    final responses = await Future.wait([
      harness.dio.get<dynamic>('products/'),
      harness.dio.get<dynamic>('inventory/'),
      harness.dio.get<dynamic>('cash-sessions/current/'),
      harness.dio.get<dynamic>('exchange-rates/current/'),
    ]);

    expect(responses.map((response) => response.statusCode), everyElement(200));
    expect(harness.refreshAdapter.countFor('auth/refresh/'), 1);
    expect(harness.sessionExpiredCalls, 0);
  });

  test('si el refresco falla, borra los tokens y avisa una sola vez', () async {
    final harness = Harness(
      storage: InMemoryTokenStorage(access: 'expired', refresh: 'expired-refresh'),
      refreshSucceeds: false,
    );

    final results = await Future.wait([
      for (final path in ['products/', 'inventory/'])
        harness.dio
            .get<dynamic>(path)
            .then((_) => 200)
            .catchError((Object error) => (error as DioException).response?.statusCode ?? 0),
    ]);

    expect(results, [401, 401]);
    expect(harness.refreshAdapter.countFor('auth/refresh/'), 1);
    expect(harness.storage.access, isNull);
    expect(harness.storage.refresh, isNull);
    expect(harness.sessionExpiredCalls, 1);
  });

  test('sin refresh token no llama al backend y cierra la sesión', () async {
    final harness = Harness(
      storage: InMemoryTokenStorage(access: 'expired'),
      refreshSucceeds: true,
    );

    await expectLater(harness.dio.get<dynamic>('products/'), throwsA(isA<DioException>()));

    expect(harness.refreshAdapter.requests, isEmpty);
    expect(harness.sessionExpiredCalls, 1);
  });

  test('un 401 tras el reintento no entra en bucle', () async {
    final harness = Harness(
      storage: InMemoryTokenStorage(access: 'expired', refresh: 'refresh'),
      refreshSucceeds: true,
    );
    // El backend rechaza también el token nuevo.
    harness.dio.httpClientAdapter = FakeHttpAdapter((_) => unauthorized);

    await expectLater(harness.dio.get<dynamic>('products/'), throwsA(isA<DioException>()));

    expect(harness.refreshAdapter.countFor('auth/refresh/'), 1);
  });
}
