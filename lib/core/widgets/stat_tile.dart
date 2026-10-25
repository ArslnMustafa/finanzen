import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'app_card.dart';

/// Small card with a label and a number, used in the 2×2 grid on the asset
/// detail screen.
class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.secondary,
  });

  final String label;
  final String value;
  final Color? valueColor;

  /// Optional second line, e.g. the percentage under a profit figure.
  final String? secondary;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: AppText.captionSmall),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppText.numberStat.copyWith(color: valueColor),
            maxLines: 1,
          ),
          if (secondary != null) ...[
            const SizedBox(height: 3),
            Text(
              secondary!,
              style: AppText.numberSmall.copyWith(
                color: valueColor ?? AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
