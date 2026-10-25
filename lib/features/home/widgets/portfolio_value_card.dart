import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/calc/portfolio_math.dart';
import '../../../core/format/money.dart';
import '../../../core/widgets/change_pill.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../data/models/price_point.dart';
import '../../../theme/app_theme.dart';

/// The accent card at the top of the home screen: total value, today's move
/// and the shape of the last seven days.
class PortfolioValueCard extends StatelessWidget {
  const PortfolioValueCard({
    super.key,
    required this.summary,
    required this.history,
  });

  final PortfolioSummary? summary;
  final List<PricePoint> history;

  @override
  Widget build(BuildContext context) {
    final summary = this.summary;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(AppRadius.largeCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Toplam portföy değeri',
            style: AppText.captionSmall.copyWith(
              color: AppColors.onAccent.withValues(alpha: 0.72),
            ),
          ),
          const SizedBox(height: 8),
          if (summary == null)
            const SkeletonBox(width: 200, height: 34, radius: 10)
          else
            Text(
              Fmt.price(
                summary.totalValue.toDouble(),
                currency: summary.baseCurrency,
              ),
              style: AppText.priceHero.copyWith(color: AppColors.onAccent),
              maxLines: 1,
            ),
          const SizedBox(height: 12),
          if (summary != null)
            Row(
              children: [
                ChangePill(
                  amount: summary.dayChange.toDouble(),
                  percent: summary.dayChangePct,
                  currency: summary.baseCurrency,
                ),
                const SizedBox(width: 10),
                Text(
                  'bugün',
                  style: AppText.captionSmall.copyWith(
                    color: AppColors.onAccent.withValues(alpha: 0.72),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 10),
          SizedBox(
            height: 74,
            child: history.length < 2
                ? const SizedBox.shrink()
                : _SevenDayChart(history: history),
          ),
        ],
      ),
    );
  }
}

class _SevenDayChart extends StatelessWidget {
  const _SevenDayChart({required this.history});

  final List<PricePoint> history;

  @override
  Widget build(BuildContext context) {
    final spots = [
      for (var i = 0; i < history.length; i++)
        FlSpot(i.toDouble(), history[i].price),
    ];
    final values = history.map((p) => p.price).toList();
    final min = values.reduce((a, b) => a < b ? a : b);
    final max = values.reduce((a, b) => a > b ? a : b);
    final padding = (max - min) * 0.25 + 1;

    return LineChart(
      LineChartData(
        minY: min - padding,
        maxY: max + padding,
        titlesData: const FlTitlesData(show: false),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        lineTouchData: const LineTouchData(enabled: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.28,
            color: AppColors.onAccent,
            barWidth: 2.2,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.onAccent.withValues(alpha: 0.12),
            ),
          ),
        ],
      ),
    );
  }
}
