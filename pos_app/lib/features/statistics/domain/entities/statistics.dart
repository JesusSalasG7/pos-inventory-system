import 'package:decimal/decimal.dart';
import 'package:flutter/foundation.dart';
import 'package:pos_app/core/domain/enums.dart';

/// Rango de días de calendario de la tienda, ambos incluidos.
@immutable
class StatsPeriod {
  const StatsPeriod({required this.from, required this.to});

  final DateTime from;
  final DateTime to;

  @override
  bool operator ==(Object other) => other is StatsPeriod && other.from == from && other.to == to;

  @override
  int get hashCode => Object.hash(from, to);
}

/// Atajos del selector de período.
enum StatsRange {
  days7(7),
  days30(30),
  days90(90),
  custom(null);

  const StatsRange(this.days);

  /// Días que abarca, contando hoy; `null` en el rango personalizado.
  final int? days;
}

/// Categoría en la que entró el usuario desde el gráfico.
@immutable
class StatsCategory {
  const StatsCategory({required this.id, required this.name});

  final int id;
  final String name;

  @override
  bool operator ==(Object other) => other is StatsCategory && other.id == id && other.name == name;

  @override
  int get hashCode => Object.hash(id, name);
}

/// Filtros globales de la pantalla: aplican a todas las secciones.
@immutable
class StatsFilter {
  const StatsFilter({required this.range, required this.period, this.category});

  /// Los últimos `range.days` días hasta `today` (fecha de calendario de la tienda).
  factory StatsFilter.lastDays(
    StatsRange range, {
    required DateTime today,
    StatsCategory? category,
  }) {
    assert(range.days != null, 'El rango personalizado necesita sus fechas');
    return StatsFilter(
      range: range,
      period: StatsPeriod(
        from: today.subtract(Duration(days: range.days! - 1)),
        to: today,
      ),
      category: category,
    );
  }

  final StatsRange range;
  final StatsPeriod period;

  /// `null`: vista general, agrupada por categoría.
  final StatsCategory? category;

  StatsFilter withCategory(StatsCategory? category) =>
      StatsFilter(range: range, period: period, category: category);

  @override
  bool operator ==(Object other) =>
      other is StatsFilter &&
      other.range == range &&
      other.period == period &&
      other.category == category;

  @override
  int get hashCode => Object.hash(range, period, category);
}

/// Métricas de un período. Los importes van en USD; `margin` es un porcentaje.
@immutable
class StatsKpis {
  const StatsKpis({
    required this.revenue,
    required this.profit,
    required this.margin,
    required this.units,
    required this.salesCount,
    required this.averageTicket,
  });

  final Decimal revenue;
  final Decimal profit;
  final Decimal margin;
  final Decimal units;
  final int salesCount;
  final Decimal averageTicket;
}

/// Variación de cada métrica contra el período anterior, en porcentaje;
/// `margin` va en puntos porcentuales. `null`: no hay con qué comparar.
@immutable
class StatsKpiChanges {
  const StatsKpiChanges({
    this.revenue,
    this.profit,
    this.margin,
    this.units,
    this.salesCount,
    this.averageTicket,
  });

  final Decimal? revenue;
  final Decimal? profit;
  final Decimal? margin;
  final Decimal? units;
  final Decimal? salesCount;
  final Decimal? averageTicket;
}

@immutable
class StatsSummary {
  const StatsSummary({
    required this.period,
    required this.previousPeriod,
    required this.current,
    required this.previous,
    required this.change,
  });

  final StatsPeriod period;
  final StatsPeriod previousPeriod;
  final StatsKpis current;
  final StatsKpis previous;
  final StatsKpiChanges change;

  bool get hasSales => current.salesCount > 0;
}

/// Ingresos y ganancia de una parte de las ventas (contado o crédito).
@immutable
class SplitTotals {
  const SplitTotals({required this.revenue, required this.profit, required this.margin});

  final Decimal revenue;
  final Decimal profit;
  final Decimal margin;
}

/// Reparto del período entre lo vendido de contado y lo vendido a crédito.
///
/// Una venta a crédito cuenta entera el día en que se factura; si solo una
/// parte quedó como deuda, se reparte en esa proporción.
@immutable
class CreditBreakdown {
  const CreditBreakdown({
    required this.cash,
    required this.credit,
    required this.pendingRevenue,
    required this.pendingProfit,
    required this.creditShare,
  });

  final SplitTotals cash;
  final SplitTotals credit;

  /// Lo que sigue sin cobrarse hoy de las ventas a crédito del período.
  final Decimal pendingRevenue;

  /// Ganancia que corresponde a lo que falta por cobrar.
  final Decimal pendingProfit;

  /// Porcentaje de los ingresos que se vendió a crédito.
  final Decimal creditShare;

  bool get hasCreditSales => credit.revenue > Decimal.zero;
}

/// Nivel que devuelve el rendimiento por grupo.
enum GroupLevel {
  category('category'),
  subcategory('subcategory');

  const GroupLevel(this.apiValue);
  final String apiValue;

  static GroupLevel fromApi(String value) =>
      values.firstWhere((e) => e.apiValue == value, orElse: () => category);
}

/// Rendimiento de una categoría o subcategoría.
@immutable
class GroupPerformance {
  const GroupPerformance({
    required this.id,
    required this.name,
    required this.units,
    required this.revenue,
    required this.profit,
    required this.margin,
  });

  /// `null`: los productos sin subcategoría.
  final int? id;
  final String name;
  final Decimal units;
  final Decimal revenue;
  final Decimal profit;
  final Decimal margin;
}

@immutable
class GroupReport {
  const GroupReport({required this.level, required this.groups});

  final GroupLevel level;

  /// Ordenados por ganancia, de mayor a menor.
  final List<GroupPerformance> groups;
}

/// Métrica por la que se ordena el ranking de productos.
enum RankingOrder {
  units('units'),
  revenue('revenue'),
  profit('profit'),
  margin('margin');

  const RankingOrder(this.apiValue);
  final String apiValue;
}

@immutable
class ProductPerformance {
  const ProductPerformance({
    required this.productId,
    required this.name,
    required this.unit,
    required this.categoryName,
    required this.units,
    required this.revenue,
    required this.profit,
    required this.margin,
    this.subcategoryName,
  });

  final int productId;
  final String name;
  final UnitOfMeasure unit;
  final String categoryName;
  final String? subcategoryName;
  final Decimal units;
  final Decimal revenue;
  final Decimal profit;
  final Decimal margin;
}

/// Cuadrante de la matriz volumen vs. margen, con cortes en las medianas.
enum Quadrant {
  /// Vende mucho y deja buen margen.
  star('STAR'),

  /// Vende mucho con poco margen.
  volumeDriver('VOLUME_DRIVER'),

  /// Vende poco con buen margen.
  profitableNiche('PROFITABLE_NICHE'),

  /// Vende poco y deja poco margen.
  review('REVIEW');

  const Quadrant(this.apiValue);
  final String apiValue;

  static Quadrant fromApi(String value) =>
      values.firstWhere((e) => e.apiValue == value, orElse: () => review);
}

@immutable
class MatrixPoint {
  const MatrixPoint({
    required this.productId,
    required this.name,
    required this.unit,
    required this.units,
    required this.revenue,
    required this.profit,
    required this.margin,
    required this.quadrant,
  });

  final int productId;
  final String name;
  final UnitOfMeasure unit;
  final Decimal units;
  final Decimal revenue;
  final Decimal profit;
  final Decimal margin;
  final Quadrant quadrant;
}

@immutable
class StatsMatrix {
  const StatsMatrix({
    required this.medianUnits,
    required this.medianMargin,
    required this.products,
  });

  final Decimal medianUnits;
  final Decimal medianMargin;
  final List<MatrixPoint> products;

  int countOf(Quadrant quadrant) => products.where((point) => point.quadrant == quadrant).length;
}

/// Producto con stock que lleva tiempo sin venderse.
@immutable
class NoMovementItem {
  const NoMovementItem({
    required this.productId,
    required this.name,
    required this.unit,
    required this.stock,
    required this.immobilizedCapital,
    this.lastSaleDate,
  });

  final int productId;
  final String name;
  final UnitOfMeasure unit;
  final Decimal stock;

  /// Fecha de calendario de la última venta; `null` si nunca se vendió.
  final DateTime? lastSaleDate;

  /// Stock × costo actual, en USD.
  final Decimal immobilizedCapital;
}

/// Producto cuyo stock se acaba pronto al ritmo de venta reciente.
@immutable
class RunningOutItem {
  const RunningOutItem({
    required this.productId,
    required this.name,
    required this.unit,
    required this.stock,
    required this.daysLeft,
  });

  final int productId;
  final String name;
  final UnitOfMeasure unit;
  final Decimal stock;
  final Decimal daysLeft;
}

@immutable
class InventoryHealth {
  const InventoryHealth({
    required this.immobilizedCapitalTotal,
    required this.noMovement,
    required this.runningOut,
  });

  final Decimal immobilizedCapitalTotal;

  /// Ordenados por capital inmovilizado, de mayor a menor.
  final List<NoMovementItem> noMovement;

  /// Ordenados por días restantes, de menor a mayor.
  final List<RunningOutItem> runningOut;
}
