import 'package:flutter/material.dart';

import '../../../data/models/asset.dart';
import '../../../theme/app_theme.dart';

/// Horizontally scrolling chips: Kripto, BIST, ABD, Fonlar, Döviz & Altın.
class MarketTabs extends StatelessWidget {
  const MarketTabs({super.key, required this.selected, required this.onSelect});

  final MarketTab selected;
  final ValueChanged<MarketTab> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSpacing.minTapTarget,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: MarketTab.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final tab = MarketTab.values[index];
          final isSelected = tab == selected;
          return Center(
            child: Material(
              color: isSelected ? AppColors.accent : AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.pill),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => onSelect(tab),
                child: Container(
                  height: 36,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    border: Border.all(
                      color: isSelected ? AppColors.accent : AppColors.border,
                    ),
                  ),
                  child: Text(
                    tab.label,
                    style: AppText.captionSmall.copyWith(
                      fontSize: 13,
                      color: isSelected
                          ? AppColors.onAccent
                          : AppColors.textSecondary,
                      fontWeight: isSelected
                          ? FontWeight.w800
                          : FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
