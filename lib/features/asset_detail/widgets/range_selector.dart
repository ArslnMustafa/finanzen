import 'package:flutter/material.dart';

import '../../../data/models/price_point.dart';
import '../../../theme/app_theme.dart';

/// 1S · 1G · 1H · 1A · 1Y · Tümü
class RangeSelector extends StatelessWidget {
  const RangeSelector({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  final ChartRange selected;
  final ValueChanged<ChartRange> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.button),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          for (final range in ChartRange.values)
            Expanded(
              child: Semantics(
                button: true,
                selected: range == selected,
                label: '${range.label} aralığı',
                child: InkWell(
                  onTap: () => onSelect(range),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: range == selected
                          ? AppColors.segmentSelected
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      range.label,
                      style: AppText.captionSmall.copyWith(
                        fontSize: 12.5,
                        color: range == selected
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
