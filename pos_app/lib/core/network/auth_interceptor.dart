import 'dart:async';

import 'package:dio/dio.dart';

import 'package:pos_app/core/storage/token_storage.dart';

/// Agrega el token Bearer y renueva el access cuando vence.
///
/// - Ante un 401 refresca y reintenta la petición UNA sola vez.
/// - Las peticiones concurrentes que fallan a la vez esperan un único
///   refresco (un `Completer` compartido), no uno cada una.
/// - Si el refresco falla se borran los tokens y se avisa con
///   `onSessionExpired` para volver al login.
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this.tokenStorage,
    required this.refreshDio,
    required this.retryDio,
    required this.onSessionExpired,
  });

  static const String loginPath = 'auth/login/';
  static const String refreshPath = 'auth/refresh/';
  static const String _retriedKey = 'auth_retried';
  static const String _authorization = 'Authorization';

  final TokenStorage tokenStorage;

  /// Cliente sin interceptores, solo para llamar a `auth/refresh/`.
  final Dio refreshDio;

  /// Cliente con el que se reintenta la petición original.
  final Dio retryDio;
  final void Function() onSessionExpired;

  Completer<String?>? _refreshing;

  static bool _isPublic(RequestOptions options) =>
      options.path.endsWith(loginPath) || options.path.endsWith(refreshPath);

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (!_isPublic(options)) {
      final access = await tokenStorage.readAccess();
      if (access != null) options.headers[_authorization] = 'Bearer $access';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final options = err.requestOptions;
    final alreadyRetried = options.extra[_retriedKey] == true;
    if (err.response?.statusCode != 401 || _isPublic(options) || alreadyRetried) {
      handler.next(err);
      return;
    }

    // Otra petición pudo renovar el token mientras esta estaba en vuelo.
    final current = await tokenStorage.readAccess();
    final sentWithCurrent = options.headers[_authorization] == 'Bearer $current';
    final access = (current != null && !sentWithCurrent) ? current : await _refreshAccess();
    if (access == null) {
      handler.next(err);
      return;
    }

    options.extra[_retriedKey] = true;
    options.headers[_authorization] = 'Bearer $access';
    try {
      handler.resolve(await retryDio.fetch<dynamic>(options));
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  /// Renueva el access. Todas las llamadas simultáneas comparten el mismo futuro.
  Future<String?> _refreshAccess() {
    final inFlight = _refreshing;
    if (inFlight != null) return inFlight.future;

    final completer = Completer<String?>();
    _refreshing = completer;
    unawaited(_runRefresh(completer));
    return completer.future;
  }

  Future<void> _runRefresh(Completer<String?> completer) async {
    String? access;
    try {
      final refresh = await tokenStorage.readRefresh();
      if (refresh != null) {
        final response = await refreshDio.post<Map<String, dynamic>>(
          refreshPath,
          data: {'refresh': refresh},
        );
        access = response.data?['access'] as String?;
      }
      if (access != null) {
        await tokenStorage.save(access: access);
      } else {
        await _expireSession();
      }
    } on Object {
      access = null;
      await _expireSession();
    } finally {
      _refreshing = null;
      completer.complete(access);
    }
  }

  Future<void> _expireSession() async {
    await tokenStorage.clear();
    onSessionExpired();
  }
}
