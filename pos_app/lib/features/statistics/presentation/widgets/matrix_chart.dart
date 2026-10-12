import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:pos_app/core/currency/money_formatter.dart';
import 'package:pos_app/core/l10n/strings.dart';
import 'package:pos_app/core/theme/app_colors.dart';
import 'package:pos_app/core/theme/app_radius.dart';
import 'package:pos_app/core/theme/app_spacing.dart';
import 'package:pos_app/core/theme/app_typography.dart';
import 'package:pos_app/features/statistics/domain/entities/statistics.dart';
import 'package:pos_app/features/statistics/presentation/widgets/stats_format.dart';
import 'package:pos_app/features/statistics/presentation/widgets/stats_section.dart';

/// Color, nombre y acción sugerida de cada cuadrante de la matriz.
abstract final class QuadrantStyle {
  static const Color _volume = AppColors.categoryLiquids;
  static const Color _niche = Color(0xFFF79009);

  static Color color(Quadrant quadrant) => switch (quadrant) {
    Quadrant.star => AppColors.primary,
    Quadrant.volumeDriver => _volume,
    Quadrant.profitableNiche => _niche,
    Quadrant.review => AppColors.error,
  };

  static String label(Quadrant quadrant) => switch (quadrant) {
    Quadrant.star => Strings.statsQuadrantStar,
    Quadrant.volumeDriver => Strings.statsQuadrantVolume,
    Quadrant.profitableNiche => Strings.statsQuadrantNiche,
    Quadrant.review => Strings.statsQuadrantReview,
  };

  static String action(Quadrant quadrant) => switch (quadrant) {
    Quadrant.star => Strings.statsActionStar,
    Quadrant.volumeDriver => Strings.statsActionVolume,
    Quadrant.profitableNiche => Strings.statsActionNiche,
    Quadrant.review => Strings.statsActionReview,
  };
}

/// Dispersión de los productos por unidades vendidas (X) y margen % (Y), con
/// las medianas marcadas y cada punto coloreado según su cuadrante.
///
/// Tocar un punto muestra el producto y sus cifras bajo el gráfico.
class MatrixChart extends StatefulWidget {
  const MatrixChart({required this.matrix, super.key});

  final StatsMatrix matrix;

  @override
  State<MatrixChart> createState() => _MatrixChartState();
}

class _MatrixChartState extends State<MatrixChart> {
  int? _selectedProductId;

  @override
  Widget build(BuildContext context) {
    final matrix = widget.matrix;
    final points = matrix.products;
    if (points.isEmpty) return const StatsEmptyNote();

    final selected = points.where((point) => point.productId == _selectedProductId).firstOrNull;
    final units = [for (final point in points) point.units.toDouble()];
    final margins = [for (final point in points) point.margin.toDouble()];
    final maxX = math.max(units.reduce(math.max), 1) * 1.1;
    // El eje Y admite márgenes negativos y siempre incluye el cero.
    final highest = math.max(margins.reduce(math.max), 0).toDouble();
    final lowest = math.min(margins.reduce(math.min), 0).toDouble();
    final padding = math.max((highest - lowest) * 0.12, 5).toDouble();
    final minY = lowest < 0 ? lowest - padding : 0.0;
    final maxY = highest + padding;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(Strings.statsMatrixHint, style: AppTypography.bodySmall),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 260,
          child: CustomPaint(
            // Las medianas dividen el plano en los cuatro cuadrantes.
            foregroundPainter: _MedianLinesPainter(
              medianX: matrix.medianUnits.toDouble(),
              medianY: matrix.medianMargin.toDouble(),
              minX: 0,
              maxX: maxX,
              minY: minY,
              maxY: maxY,
            ),
            child: ScatterChart(
              ScatterChartData(
                minX: 0,
                maxX: maxX,
                minY: minY,
                maxY: maxY,
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),
                  leftTitles: AxisTitles(
                    axisNameWidget: Text(Strings.statsMatrixAxisY, style: _axisName),
                    axisNameSize: _axisNameSize,
                    sideTitles: const SideTitles(
                      showTitles: true,
                      reservedSize: _leftTicksSize,
                      getTitlesWidget: _tick,
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    axisNameWidget: Text(Strings.statsMatrixAxisX, style: _axisName),
                    axisNameSize: _axisNameSize,
                    sideTitles: const SideTitles(
                      showTitles: true,
                      reservedSize: _bottomTicksSize,
                      getTitlesWidget: _tick,
                    ),
                  ),
                ),
                scatterSpots: [
                  for (final point in points)
                    ScatterSpot(
                      point.units.toDouble(),
                      point.margin.toDouble(),
                      // El elegido se pinta encima y más grande.
                      renderPriority: point.productId == _selectedProductId ? 1 : 0,
                      dotPainter: FlDotCirclePainter(
                        radius: point.productId == _selectedProductId ? 9 : 6,
                        color: QuadrantStyle.color(point.quadrant),
                        strokeWidth: 2,
                        strokeColor: AppColors.surface,
                      ),
                    ),
                ],
                scatterTouchData: ScatterTouchData(
                  handleBuiltInTouches: false,
                  // Área táctil mayor que el punto.
                  touchSpotThreshold: 16,
                  touchCallback: (event, response) {
                    final index = response?.touchedSpot?.spotIndex;
                    if (index == null || index >= points.length) return;
                    final productId = points[index].productId;
                    if (productId != _selectedProductId) {
                      setState(() => _selectedProductId = productId);
                    }
                  },
                ),
              ),
            ),
          ),
        ),
        if (selected != null) ...[
          const SizedBox(height: AppSpacing.md),
          _SelectedPoint(point: selected),
        ],
        const SizedBox(height: AppSpacing.md),
        for (final quadrant in Quadrant.values)
          _QuadrantLegend(quadrant: quadrant, count: matrix.countOf(quadrant)),
      ],
    );
  }

  // Espacio que ocupan los ejes: el pintor de las medianas lo descuenta.
  static const double _axisNameSize = 18;
  static const double _leftTicksSize = 40;
  static const double _bottomTicksSize = 28;

  static final TextStyle _axisName = AppTypography.label.copyWith(color: AppColors.textMuted);

  static Widget _tick(double value, TitleMeta meta) {
    // Los extremos del eje no caen en un valor redondo: se omiten.
    if (value == meta.min || value == meta.max) return const SizedBox.shrink();
    return SideTitleWidget(
      meta: meta,
      child: Text(
        StatsFormat.compact(value),
        style: AppTypography.label.copyWith(color: AppColors.textMuted),
      ),
    );
  }
}

/// Líneas discontinuas en la mediana de cada eje, sobre el área del gráfico.
///
/// `ScatterChart` no admite líneas extra, así que se pintan encima
/// descontando el espacio de los ejes izquierdo e inferior.
class _MedianLinesPainter extends CustomPainter {
  const _MedianLinesPainter({
    required this.medianX,
    required this.medianY,
    required this.minX,
    required this.maxX,
    required this.minY,
    required this.maxY,
  });

  final double medianX;
  final double medianY;
  final double minX;
  final double maxX;
  final double minY;
  final double maxY;

  @override
  void paint(Canvas canvas, Size size) {
    const left = _MatrixChartState._axisNameSize + _MatrixChartState._leftTicksSize;
    const bottom = _MatrixChartState._axisNameSize + _MatrixChartState._bottomTicksSize;
    final plot = Rect.fromLTRB(left, 0, size.width, size.height - bottom);
    if (plot.width <= 0 || plot.height <= 0) return;
    final paint = Paint()
      ..color = AppColors.textMuted
      ..strokeWidth = 1;

    final x = plot.left + (medianX - minX) / (maxX - minX) * plot.width;
    final y = plot.bottom - (medianY - minY) / (maxY - minY) * plot.height;
    const dash = 4.0;
    for (var top = plot.top; top < plot.bottom; top += dash * 2) {
      canvas.drawLine(Offset(x, top), Offset(x, math.min(top + dash, plot.bottom)), paint);
    }
    for (var start = plot.left; start < plot.right; start += dash * 2) {
      canvas.drawLine(Offset(start, y), Offset(math.min(start + dash, plot.right), y), paint);
    }
  }

  @override
  bool shouldRepaint(_MedianLinesPainter old) =>
      old.medianX != medianX ||
      old.medianY != medianY ||
      old.minX != minX ||
      old.maxX != maxX ||
      old.minY != minY ||
      old.maxY != maxY;
}

/// Ficha del producto tocado en la matriz.
class _SelectedPoint extends StatelessWidget {
  const _SelectedPoint({required this.point});

  final MatrixPoint point;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('stats-matrix-selected'),
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: const BoxDecoration(color: AppColors.surfaceMuted, borderRadius: AppRadius.smAll),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StatsSwatch(color: QuadrantStyle.color(point.quadrant), round: true),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  point.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.subtitle,
                ),
              ),
              Text(QuadrantStyle.label(point.quadrant), style: AppTypography.label),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '${StatsFormat.quantity(point.units, point.unit)} · '
            '${Strings.statsMargin} ${StatsFormat.percent(point.margin)} · '
            '${Strings.statsProfit} ${MoneyFormatter.usd(point.profit)}',
            style: AppTypography.bodySmall,
          ),
        ],
      ),
    );
  }
}

/// Fila de la leyenda: cuadrante, cuántos productos tiene y qué hacer con ellos.
class _QuadrantLegend extends StatelessWidget {
  const _QuadrantLegend({required this.quadrant, required this.count});

  final Quadrant quadrant;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: ValueKey('stats-quadrant-${quadrant.name}'),
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          StatsSwatch(color: QuadrantStyle.color(quadrant), round: true),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${QuadrantStyle.label(quadrant)} ($count)',
                    style: AppTypography.subtitle.copyWith(fontSize: 14),
                  ),
                  TextSpan(
                    text: '  ${QuadrantStyle.action(quadrant)}',
                    style: AppTypography.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
