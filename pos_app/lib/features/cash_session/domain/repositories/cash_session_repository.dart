import 'package:decimal/decimal.dart';
import 'package:pos_app/core/domain/enums.dart';
import 'package:pos_app/core/network/paginated.dart';
import 'package:pos_app/features/cash_session/domain/entities/cash_session.dart';

abstract interface class CashSessionRepository {
  /// Caja abierta del usuario, o `null` si no tiene ninguna.
  Future<CashSession?> fetchCurrent();

  /// Abre una caja en la sucursal indicada con el fondo inicial en USD.
  Future<CashSession> open({required String branchCode, required Decimal openingFloat});

  /// Cajas de la sucursal, de la más reciente a la más antigua.
  Future<Paginated<CashSession>> fetchSessions({required String branchCode, required int page});

  /// Todos los egresos de la caja.
  Future<List<CashExpense>> fetchExpenses(int sessionId);

  Future<CashExpense> registerExpense({
    required int sessionId,
    required String reason,
    required Decimal amount,
    required Currency currency,
  });

  Future<CashCountSummary> fetchSummary(int sessionId);

  /// Cierra la caja con los montos contados. Devuelve la caja con la
  /// diferencia definitiva calculada por el backend.
  Future<CashSession> close({
    required int sessionId,
    required Decimal countedAmountUsd,
    required Decimal countedAmountVes,
  });
}
