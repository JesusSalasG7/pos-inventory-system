import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Recuerda la última tasa que el usuario vio en este dispositivo, para avisar
/// cuando cambie.
abstract interface class RateNoticeStorage {
  /// Id y valor (string decimal) de la última tasa vista, o `null` si ninguna.
  Future<({int id, String rate})?> read();
  Future<void> save({required int id, required String rate});
}

class SecureRateNoticeStorage implements RateNoticeStorage {
  SecureRateNoticeStorage([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  static const String _key = 'last_seen_rate';

  final FlutterSecureStorage _storage;

  @override
  Future<({int id, String rate})?> read() async {
    final parts = (await _storage.read(key: _key))?.split('|');
    if (parts == null || parts.length != 2) return null;
    final id = int.tryParse(parts[0]);
    return id == null ? null : (id: id, rate: parts[1]);
  }

  @override
  Future<void> save({required int id, required String rate}) =>
      _storage.write(key: _key, value: '$id|$rate');
}

/// Almacén volátil para tests.
class InMemoryRateNoticeStorage implements RateNoticeStorage {
  InMemoryRateNoticeStorage([this.value]);

  ({int id, String rate})? value;

  @override
  Future<({int id, String rate})?> read() async => value;

  @override
  Future<void> save({required int id, required String rate}) async => value = (id: id, rate: rate);
}
