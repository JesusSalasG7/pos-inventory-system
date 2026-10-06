import 'package:dio/dio.dart';
import 'package:pos_app/core/config/env.dart';
import 'package:pos_app/core/network/auth_interceptor.dart';
import 'package:pos_app/core/network/error_interceptor.dart';
import 'package:pos_app/core/network/server_reachability_provider.dart';
import 'package:pos_app/core/session/session_expired_provider.dart';
import 'package:pos_app/core/storage/token_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'api_client.g.dart';

@Riverpod(keepAlive: true)
TokenStorage tokenStorage(Ref ref) => SecureTokenStorage();

/// Cliente HTTP único de la app. Las pantallas nunca lo usan directamente:
/// solo los datasources de cada feature.
@Riverpod(keepAlive: true)
Dio dio(Ref ref) {
  final options = BaseOptions(
    baseUrl: '${Env.apiBaseUrl}${Env.apiPrefix}',
    connectTimeout: const Duration(seconds: 10),
    sendTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    contentType: Headers.jsonContentType,
    responseType: ResponseType.json,
  );
  final dio = Dio(options);
  final refreshDio = Dio(options);

  dio.interceptors.addAll([
    AuthInterceptor(
      tokenStorage: ref.watch(tokenStorageProvider),
      refreshDio: refreshDio,
      retryDio: dio,
      onSessionExpired: () => ref.read(sessionExpiredProvider.notifier).notify(),
    ),
    ErrorInterceptor(
      onReachabilityChanged: ({required reachable}) {
        ref.read(serverOfflineProvider.notifier).set(offline: !reachable);
      },
    ),
  ]);

  ref.onDispose(() {
    dio.close();
    refreshDio.close();
  });
  return dio;
}
