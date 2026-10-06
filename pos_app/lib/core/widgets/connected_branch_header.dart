import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/core/session/active_branch_provider.dart';
import 'package:pos_app/core/session/current_user_provider.dart';
import 'package:pos_app/core/widgets/branch_header.dart';
import 'package:pos_app/features/auth/presentation/providers/session_controller.dart';
import 'package:pos_app/features/exchange_rate/presentation/providers/active_rate_provider.dart';

/// [BranchHeader] conectado a la sesión: sucursal activa, permiso para
/// cambiarla y tasa del día.
class ConnectedBranchHeader extends ConsumerWidget implements PreferredSizeWidget {
  const ConnectedBranchHeader({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(BranchHeader.height);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final branch = ref.watch(activeBranchProvider);
    final branchCount = ref.watch(
      sessionControllerProvider.select((session) => session.branches.length),
    );
    final rate = ref.watch(activeRateProvider);

    return BranchHeader(
      branchName: branch?.name,
      rate: rate.value,
      isRateLoading: rate.isLoading && !rate.hasValue,
      // TODO(fase-3): estado real de la caja y navegación a Caja.
      isSessionOpen: null,
      // Solo un MANAGER con acceso a todas y más de una sede puede cambiarla.
      canChangeBranch: (user?.hasAllBranchesAccess ?? false) && branchCount > 1,
      onBranchTap: () => ref.read(sessionControllerProvider.notifier).requestBranchChange(),
    );
  }
}
