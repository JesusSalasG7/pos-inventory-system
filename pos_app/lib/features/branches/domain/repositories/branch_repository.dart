import 'package:pos_app/core/domain/branch.dart';

/// Contrato de sucursales. La administración completa (editar, desactivar)
/// se añade en la fase de administración.
abstract interface class BranchRepository {
  /// Todas las sucursales activas, ordenadas por nombre.
  Future<List<Branch>> fetchActiveBranches();

  /// Crea una sucursal. Solo MANAGER. Lanza `Failure` si el código no es
  /// válido o ya existe.
  Future<Branch> createBranch({required String code, required String name});
}
