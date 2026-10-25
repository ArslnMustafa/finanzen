import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/format/money.dart';
import '../../../data/models/price_point.dart';
import '../../../theme/app_theme.dart';

/// Line chart on the asset detail screen: dashed horizontal grid, accent
/// coloured line, no axis labels.
class PriceChart extends StatelessWidget {
  const PriceChart({
    super.key,
    required this.points,
    required this.currency,
    this.decimals,
  });

  final List<PricePoint> points;

  /// Currency the tooltip shows the price in.
  final Currency currency;

  final int? decimals;

  @override
  Widget build(BuildContext context) {
    if (points.length < 2) return const SizedBox(height: 180);

    final values = [for (final point in points) point.price];
    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);
    final padding = (max - min) * 0.12 + 0.000001;

    return SizedBox(
      height: 180,
      child: LineChart(
        LineChartData(
          minY: min - padding,
          maxY: max + padding,
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: (max - min + 2 * padding) / 4,
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppColors.border,
              strokeWidth: 1,
              dashArray: const [4, 5],
            ),
          ),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => AppColors.surfaceAlt,
              getTooltipItems: (spots) => [
                for (final spot in spots)
                  LineTooltipItem(
                    Fmt.price(spot.y, currency: currency, decimals: decimals),
                    AppText.numberSmall,
                  ),
              ],
            ),
            getTouchedSpotIndicator: (barData, indexes) => [
              for (final _ in indexes)
                TouchedSpotIndicatorData(
                  const FlLine(color: AppColors.border, strokeWidth: 1),
                  FlDotData(
                    getDotPainter: (spot, percent, bar, index) =>
                        FlDotCirclePainter(
                          radius: 3.5,
                          color: AppColors.accent,
                          strokeWidth: 0,
                        ),
                  ),
                ),
            ],
          ),
          lineBarsData: [
            LineChartBarData(
              spots: [
                for (var i = 0; i < points.length; i++)
                  FlSpot(i.toDouble(), points[i].price),
              ],
              isCurved: true,
              curveSmoothness: 0.2,
              color: AppColors.accent,
              barWidth: 2,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.accent.withValues(alpha: 0.18),
                    AppColors.accent.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
