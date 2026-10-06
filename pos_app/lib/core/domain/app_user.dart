import 'package:flutter/foundation.dart';

import 'package:pos_app/core/domain/enums.dart';

/// Usuario autenticado, tal como lo devuelve `auth/me/`.
@immutable
class AppUser {
  const AppUser({
    required this.id,
    required this.username,
    required this.fullName,
    required this.role,
    required this.assignedBranch,
    required this.isActive,
  });

  final int id;
  final String username;
  final String fullName;
  final UserRole role;

  /// Código de la sucursal asignada; `null` significa acceso a todas (solo MANAGER).
  final String? assignedBranch;
  final bool isActive;

  bool get isManager => role == UserRole.manager;

  /// Solo un MANAGER sin sucursal asignada puede operar en todas.
  bool get hasAllBranchesAccess => isManager && assignedBranch == null;

  @override
  bool operator ==(Object other) =>
      other is AppUser &&
      other.id == id &&
      other.username == username &&
      other.fullName == fullName &&
      other.role == role &&
      other.assignedBranch == assignedBranch &&
      other.isActive == isActive;

  @override
  int get hashCode => Object.hash(id, username, fullName, role, assignedBranch, isActive);
}
