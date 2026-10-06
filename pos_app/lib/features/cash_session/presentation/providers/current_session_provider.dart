import 'package:decimal/decimal.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/core/domain/enums.dart';
import 'package:pos_app/core/network/paged_list.dart';
import 'package:pos_app/core/session/active_branch_provider.dart';
import 'package:pos_app/features/auth/presentation/providers/session_controller.dart';
import 'package:pos_app/features/cash_session/data/repositories/cash_session_repository_impl.dart';
import 'package:pos_app/features/cash_session/domain/entities/cash_session.dart';
import 'package:pos_app/features/home/presentation/providers/dashboard_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'current_session_provider.g.dart';

/// Caja abierta del usuario; `null` si no tiene ninguna.
///
/// El backend permite una sola caja abierta por usuario, en cualquier
/// sucursal: puede pertenecer a una distinta de la activa.
@Riverpod(keepAlive: true)
class CurrentSession extends _$CurrentSession {
  @override
  Future<CashSession?> build() async {
    final status = ref.watch(sessionControllerProvider.select((session) => session.status));
    // Se vuelve a consultar al cambiar de sucursal.
    ref.watch(activeBranchProvider);
    if (status != SessionStatus.ready) return null;
    return ref.watch(cashSessionRepositoryProvider).fetchCurrent();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }

  /// Abre una caja en la sucursal activa. Lanza `Failure`.
  Future<CashSession> open({required Decimal openingFloat}) async {
    final branch = ref.read(activeBranchProvider)!;
    final session = await ref
        .read(cashSessionRepositoryProvider)
        .open(branchCode: branch.code, openingFloat: openingFloat);
    state = AsyncData(session);
    ref.invalidate(cashHistoryProvider);
    return session;
  }

  /// Registra un egreso en una caja y refresca su arqueo. Lanza `Failure`.
  Future<void> registerExpense({
    required int sessionId,
    required String reason,
    required Decimal amount,
    required Currency currency,
  }) async {
    await ref
        .read(cashSessionRepositoryProvider)
        .registerExpense(sessionId: sessionId, reason: reason, amount: amount, currency: currency);
    ref
      ..invalidate(sessionExpensesProvider(sessionId))
      ..invalidate(sessionSummaryProvider(sessionId));
  }

  /// Cierra la caja. Devuelve la caja cerrada con la diferencia definitiva.
  Future<CashSession> close({
    required int sessionId,
    required Decimal countedAmountUsd,
    required Decimal countedAmountVes,
  }) async {
    final closed = await ref
        .read(cashSessionRepositoryProvider)
        .close(
          sessionId: sessionId,
          countedAmountUsd: countedAmountUsd,
          countedAmountVes: countedAmountVes,
        );
    if (state.value?.id == sessionId) state = const AsyncData(null);
    ref
      ..invalidate(cashHistoryProvider)
      ..invalidate(todaySalesSummaryProvider);
    return closed;
  }
}

/// Egresos de una caja.
@riverpod
Future<List<CashExpense>> sessionExpenses(Ref ref, int sessionId) =>
    ref.watch(cashSessionRepositoryProvider).fetchExpenses(sessionId);

/// Arqueo de una caja: efectivo esperado según ventas y egresos.
@riverpod
Future<CashCountSummary> sessionSummary(Ref ref, int sessionId) =>
    ref.watch(cashSessionRepositoryProvider).fetchSummary(sessionId);

/// Historial de cajas de la sucursal activa, cargado página a página.
@riverpod
class CashHistory extends _$CashHistory {
  bool _loadingMore = false;

  @override
  Future<PagedList<CashSession>> build() async {
    final branch = ref.watch(activeBranchProvider);
    if (branch == null) return const PagedList(items: [], totalCount: 0, nextPage: null);
    final page = await ref
        .watch(cashSessionRepositoryProvider)
        .fetchSessions(branchCode: branch.code, page: 1);
    return PagedList.first(page);
  }

  Future<void> loadMore() async {
    final current = state.value;
    final nextPage = current?.nextPage;
    final branch = ref.read(activeBranchProvider);
    if (current == null || nextPage == null || branch == null || _loadingMore) return;
    _loadingMore = true;
    try {
      final page = await ref
          .read(cashSessionRepositoryProvider)
          .fetchSessions(branchCode: branch.code, page: nextPage);
      state = AsyncData(current.append(page));
    } finally {
      _loadingMore = false;
    }
  }
}
