import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Recuerda la última sucursal elegida por un MANAGER con varias sedes, para
/// no preguntarla cada vez que se abre la app.
abstract interface class BranchPreferenceStorage {
  Future<String?> read();
  Future<void> save(String branchCode);
  Future<void> clear();
}

class SecureBranchPreferenceStorage implements BranchPreferenceStorage {
  SecureBranchPreferenceStorage([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  static const String _key = 'active_branch_code';

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read() => _storage.read(key: _key);

  @override
  Future<void> save(String branchCode) => _storage.write(key: _key, value: branchCode);

  @override
  Future<void> clear() => _storage.delete(key: _key);
}

/// Almacén volátil para tests.
class InMemoryBranchPreferenceStorage implements BranchPreferenceStorage {
  InMemoryBranchPreferenceStorage([this.branchCode]);

  String? branchCode;

  @override
  Future<String?> read() async => branchCode;

  @override
  Future<void> save(String branchCode) async => this.branchCode = branchCode;

  @override
  Future<void> clear() async => branchCode = null;
}
