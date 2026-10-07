import 'package:pos_app/core/domain/branch.dart';

/// Contrato de sucursales. Las sucursales no se borran: se desactivan.
abstract interface class BranchRepository {
  /// Todas las sucursales activas, ordenadas por nombre.
  Future<List<Branch>> fetchActiveBranches();

  /// Todas las sucursales, también las inactivas, ordenadas por nombre.
  Future<List<Branch>> fetchAllBranches();

  /// Cambia el nombre o el estado de una sucursal. Solo MANAGER. El código
  /// nunca cambia.
  Future<Branch> updateBranch(String code, {String? name, bool? active});

  /// Crea una sucursal. Solo MANAGER. Lanza `Failure` si el código no es
  /// válido o ya existe.
  Future<Branch> createBranch({required String code, required String name});
}
