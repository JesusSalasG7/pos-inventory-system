import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Almacén del par de tokens JWT.
abstract interface class TokenStorage {
  Future<String?> readAccess();
  Future<String?> readRefresh();

  /// Guarda el access y, si se indica, también el refresh.
  Future<void> save({required String access, String? refresh});
  Future<void> clear();
}

/// Guarda los tokens cifrados en el dispositivo (Keystore en Android).
class SecureTokenStorage implements TokenStorage {
  SecureTokenStorage([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  static const String _accessKey = 'access_token';
  static const String _refreshKey = 'refresh_token';

  final FlutterSecureStorage _storage;

  // Copia en memoria: evita leer del almacén cifrado en cada petición.
  String? _access;
  String? _refresh;
  bool _loaded = false;

  Future<void> _ensureLoaded() async {
    if (_loaded) return;
    _access = await _storage.read(key: _accessKey);
    _refresh = await _storage.read(key: _refreshKey);
    _loaded = true;
  }

  @override
  Future<String?> readAccess() async {
    await _ensureLoaded();
    return _access;
  }

  @override
  Future<String?> readRefresh() async {
    await _ensureLoaded();
    return _refresh;
  }

  @override
  Future<void> save({required String access, String? refresh}) async {
    _loaded = true;
    _access = access;
    await _storage.write(key: _accessKey, value: access);
    if (refresh != null) {
      _refresh = refresh;
      await _storage.write(key: _refreshKey, value: refresh);
    }
  }

  @override
  Future<void> clear() async {
    _loaded = true;
    _access = null;
    _refresh = null;
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
  }
}

/// Almacén volátil para tests.
class InMemoryTokenStorage implements TokenStorage {
  InMemoryTokenStorage({this.access, this.refresh});

  String? access;
  String? refresh;

  @override
  Future<String?> readAccess() async => access;

  @override
  Future<String?> readRefresh() async => refresh;

  @override
  Future<void> save({required String access, String? refresh}) async {
    this.access = access;
    if (refresh != null) this.refresh = refresh;
  }

  @override
  Future<void> clear() async {
    access = null;
    refresh = null;
  }
}
