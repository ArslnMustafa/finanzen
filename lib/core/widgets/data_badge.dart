import 'package:flutter/material.dart';

import '../../data/models/asset.dart';
import '../../theme/app_theme.dart';

Color _dotColor(DataDelay delay) => switch (delay) {
  DataDelay.live => AppColors.up,
  DataDelay.delayed15m => AppColors.chartOrange,
  DataDelay.daily => AppColors.chartGrey,
};

/// `● Canlı · Binance` — tells the user how fresh the number above it is.
class DataBadge extends StatelessWidget {
  const DataBadge({super.key, required this.delay, this.source});

  final DataDelay delay;
  final String? source;

  @override
  Widget build(BuildContext context) {
    final text = source == null ? delay.label : '${delay.label} · $source';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: _dotColor(delay),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 7),
        Text(text, style: AppText.caption),
      ],
    );
  }
}
