import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pos_app/core/errors/error_messages.dart';
import 'package:pos_app/core/errors/failure.dart';
import 'package:pos_app/core/network/api_exception.dart';
import 'package:pos_app/core/network/error_interceptor.dart';

/// Códigos que el backend puede devolver (ver docs/api_contracts.md).
const backendCodes = [
  'validation_error',
  'authentication_failed',
  'not_authenticated',
  'token_not_valid',
  'permission_denied',
  'not_found',
  'no_branches',
  'branch_required',
  'invalid_branch',
  'branch_access_denied',
  'branch_not_found',
  'invalid_branch_code',
  'invalid_branch_name',
  'branch_code_taken',
  'branch_has_open_sessions',
  'invalid_username',
  'invalid_full_name',
  'invalid_password',
  'invalid_branch_assignment',
  'username_taken',
  'user_not_found',
  'user_has_open_session',
  'cannot_modify_own_access',
  'invalid_name',
  'product_name_taken',
  'invalid_price',
  'product_not_found',
  'inactive_product',
  'insufficient_stock',
  'invalid_quantity',
  'invalid_movement_type',
  'exchange_rate_not_set',
  'invalid_exchange_rate',
  'bcv_rate_unavailable',
  'no_open_session',
  'session_already_open',
  'session_already_closed',
  'cash_session_not_found',
  'not_session_owner',
  'invalid_amount',
  'invalid_reason',
  'payment_mismatch',
  'invalid_payment',
  'empty_sale',
  'sale_not_found',
];

DioException badResponse(int status, Object? data) {
  final options = RequestOptions(path: 'sales/');
  return DioException(
    requestOptions: options,
    type: DioExceptionType.badResponse,
    response: Response<dynamic>(requestOptions: options, statusCode: status, data: data),
  );
}

void main() {
  group('ErrorMessages', () {
    test('todos los códigos del backend tienen mensaje propio', () {
      final missing = backendCodes.where((code) => !ErrorMessages.knownCodes.contains(code));
      expect(missing, isEmpty);
    });

    test('los códigos de red tienen mensaje propio', () {
      for (final code in [
        ApiException.timeoutCode,
        ApiException.noConnectionCode,
        ApiException.serverCode,
      ]) {
        expect(ErrorMessages.forCode(code), isNot(ErrorMessages.generic));
      }
    });

    test('un código desconocido usa el detail del backend y, si falta, el genérico', () {
      expect(
        ErrorMessages.forCode('nuevo_codigo', detail: 'Detalle del backend.'),
        'Detalle del backend.',
      );
      expect(ErrorMessages.forCode('nuevo_codigo'), ErrorMessages.generic);
      expect(ErrorMessages.forCode('nuevo_codigo', detail: '  '), ErrorMessages.generic);
    });
  });

  group('ErrorInterceptor.toApiException', () {
    test('lee el sobre {code, detail, meta} del backend', () {
      final exception = ErrorInterceptor.toApiException(
        badResponse(422, {
          'code': 'insufficient_stock',
          'detail': 'No hay stock suficiente.',
          'meta': {
            'items': [
              {'product_id': 3, 'requested': '5.000', 'available': '2.000'},
            ],
          },
        }),
      );

      expect(exception.type, ApiErrorType.api);
      expect(exception.code, 'insufficient_stock');
      expect(exception.statusCode, 422);
      expect((exception.meta['items'] as List).single, containsPair('available', '2.000'));
    });

    test('distingue timeout, sin conexión y 5xx sin sobre', () {
      final options = RequestOptions(path: 'sales/');
      ApiErrorType typeOf(DioExceptionType type) =>
          ErrorInterceptor.toApiException(DioException(requestOptions: options, type: type)).type;

      expect(typeOf(DioExceptionType.connectionTimeout), ApiErrorType.timeout);
      expect(typeOf(DioExceptionType.receiveTimeout), ApiErrorType.timeout);
      expect(typeOf(DioExceptionType.connectionError), ApiErrorType.noConnection);
      expect(ErrorInterceptor.toApiException(badResponse(502, '<html>')).type, ApiErrorType.server);
      expect(
        ErrorInterceptor.toApiException(
          badResponse(503, {
            'code': 'bcv_rate_unavailable',
            'detail': 'No se pudo obtener la tasa del BCV.',
            'meta': <String, dynamic>{},
          }),
        ).code,
        'bcv_rate_unavailable',
      );
    });
  });

  group('Failure', () {
    test('convierte un DioException ya normalizado', () {
      final dioError = badResponse(409, null).copyWith(
        error: const ApiException(
          type: ApiErrorType.api,
          code: 'no_open_session',
          statusCode: 409,
          meta: {'requested_branch': 'CENTRO'},
        ),
      );

      final failure = Failure.from(dioError);

      expect(failure.code, 'no_open_session');
      expect(failure.message, ErrorMessages.forCode('no_open_session'));
      expect(failure.meta, containsPair('requested_branch', 'CENTRO'));
      expect(failure.isOffline, isFalse);
    });

    test('un error cualquiera es un fallo genérico y guard lo relanza', () async {
      expect(Failure.from(StateError('x')).message, ErrorMessages.generic);
      await expectLater(
        Failure.guard<void>(() async => throw StateError('x')),
        throwsA(isA<Failure>()),
      );
    });
  });
}
