import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/calc/portfolio_math.dart';
import '../../../core/format/money.dart';
import '../../../core/widgets/app_card.dart';
import '../../../data/models/asset.dart';
import '../../../theme/app_theme.dart';

/// Colour per market group, in the order of [MarketTab].
Color colorForGroup(MarketTab group) => switch (group) {
  MarketTab.crypto => AppColors.accent,
  MarketTab.bist => AppColors.chartBlue,
  MarketTab.funds => AppColors.chartOrange,
  MarketTab.fxGold => AppColors.chartGrey,
  MarketTab.us => AppColors.up,
};

/// Donut on the left, legend with percentages on the right.
class AllocationCard extends StatelessWidget {
  const AllocationCard({super.key, required this.slices});

  final List<AllocationSlice> slices;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      radius: AppRadius.largeCard,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          SizedBox(
            width: 112,
            height: 112,
            child: PieChart(
              PieChartData(
                startDegreeOffset: -90,
                sectionsSpace: 3,
                centerSpaceRadius: 34,
                sections: [
                  for (final slice in slices)
                    PieChartSectionData(
                      value: slice.percent,
                      color: colorForGroup(slice.group),
                      radius: 20,
                      showTitle: false,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final slice in slices) ...[
                  _LegendRow(slice: slice),
                  if (slice != slices.last) const SizedBox(height: 10),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({required this.slice});

  final AllocationSlice slice;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: colorForGroup(slice.group),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            slice.group.label,
            style: AppText.captionSmall.copyWith(
              color: AppColors.textPrimary,
              fontSize: 13,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          Fmt.percent(slice.percent, decimals: 1),
          style: AppText.numberSmall.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}
