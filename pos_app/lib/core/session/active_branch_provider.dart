import 'package:pos_app/core/domain/branch.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'active_branch_provider.g.dart';

/// Sucursal sobre la que opera la app; `null` hasta que se resuelve tras el login.
///
/// Los repositorios envían siempre su `code` en `branch`, de modo que un MANAGER
/// con acceso a todas vea solo la sede elegida. Al cambiarla, los providers de
/// inventario, caja, ventas y reportes que la observan se recalculan solos.
@Riverpod(keepAlive: true)
class ActiveBranch extends _$ActiveBranch {
  @override
  Branch? build() => null;

  void select(Branch branch) => state = branch;

  void clear() => state = null;
}
