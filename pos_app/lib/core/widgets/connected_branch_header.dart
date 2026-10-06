import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pos_app/app/router/route_names.dart';
import 'package:pos_app/core/session/active_branch_provider.dart';
import 'package:pos_app/core/session/current_user_provider.dart';
import 'package:pos_app/core/widgets/branch_header.dart';
import 'package:pos_app/features/auth/presentation/providers/session_controller.dart';
import 'package:pos_app/features/cash_session/presentation/providers/current_session_provider.dart';
import 'package:pos_app/features/exchange_rate/presentation/providers/active_rate_provider.dart';

/// [BranchHeader] conectado a la sesión: sucursal activa, permiso para
/// cambiarla, tasa del día y estado de la caja.
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
    final cashSession = ref.watch(currentSessionProvider);
    // La caja cuenta como abierta solo si es de la sucursal activa.
    final isSessionOpen = cashSession.hasValue
        ? cashSession.value != null && cashSession.value!.branchCode == branch?.code
        : null;

    return BranchHeader(
      branchName: branch?.name,
      rate: rate.value,
      isRateLoading: rate.isLoading && !rate.hasValue,
      isSessionOpen: isSessionOpen,
      onSessionTap: () => context.go(RouteNames.cash),
      // Solo un MANAGER con acceso a todas y más de una sede puede cambiarla.
      canChangeBranch: (user?.hasAllBranchesAccess ?? false) && branchCount > 1,
      onBranchTap: () => ref.read(sessionControllerProvider.notifier).requestBranchChange(),
    );
  }
}
