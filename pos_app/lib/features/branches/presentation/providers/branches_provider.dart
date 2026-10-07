import 'package:pos_app/core/domain/branch.dart';
import 'package:pos_app/features/auth/presentation/providers/session_controller.dart';
import 'package:pos_app/features/branches/data/repositories/branch_repository_impl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'branches_provider.g.dart';

/// Todas las tiendas del negocio, también las inactivas. Concentra las
/// operaciones de un MANAGER sobre ellas.
@riverpod
class AllBranches extends _$AllBranches {
  @override
  Future<List<Branch>> build() => ref.watch(branchRepositoryProvider).fetchAllBranches();

  /// La sesión guarda la lista de tiendas activas (selector, cabecera,
  /// formularios): hay que volver a leerla tras cada cambio.
  Future<void> _refresh() async {
    ref.invalidateSelf();
    await ref.read(sessionControllerProvider.notifier).refreshBranches();
  }

  /// Crea una tienda con stock cero de todos los productos. Lanza `Failure`.
  Future<Branch> create({required String code, required String name}) async {
    final branch = await ref.read(branchRepositoryProvider).createBranch(code: code, name: name);
    await _refresh();
    return branch;
  }

  /// Cambia el nombre de una tienda. Lanza `Failure`.
  Future<Branch> rename(String code, String name) async {
    final branch = await ref.read(branchRepositoryProvider).updateBranch(code, name: name);
    await _refresh();
    return branch;
  }

  /// Activa o desactiva una tienda. Lanza `Failure` (p. ej. si tiene cajas abiertas).
  Future<Branch> setActive(String code, {required bool active}) async {
    final branch = await ref.read(branchRepositoryProvider).updateBranch(code, active: active);
    await _refresh();
    return branch;
  }
}
