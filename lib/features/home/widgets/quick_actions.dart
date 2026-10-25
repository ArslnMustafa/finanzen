import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../theme/app_theme.dart';

/// Four shortcuts under the portfolio card.
class QuickActions extends StatelessWidget {
  const QuickActions({
    super.key,
    required this.onAddHolding,
    required this.onCreateAlert,
    required this.onMarkets,
    required this.onSearch,
  });

  final VoidCallback onAddHolding;
  final VoidCallback onCreateAlert;
  final VoidCallback onMarkets;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    final actions = <({IconData icon, String label, VoidCallback onTap})>[
      (icon: LucideIcons.plus, label: 'Varlık ekle', onTap: onAddHolding),
      (icon: LucideIcons.bell, label: 'Alarm kur', onTap: onCreateAlert),
      (
        icon: LucideIcons.chartCandlestick,
        label: 'Piyasalar',
        onTap: onMarkets,
      ),
      (icon: LucideIcons.search, label: 'Ara', onTap: onSearch),
    ];

    return Row(
      children: [
        for (var i = 0; i < actions.length; i++) ...[
          if (i > 0) const SizedBox(width: AppSpacing.card),
          Expanded(
            child: _QuickAction(
              icon: actions[i].icon,
              label: actions[i].label,
              onTap: actions[i].onTap,
            ),
          ),
        ],
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.smallCard),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 88,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(AppRadius.smallCard),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 17, color: AppColors.iconBoxText),
              ),
              const SizedBox(height: 9),
              Flexible(
                child: Text(
                  label,
                  style: AppText.captionSmall.copyWith(fontSize: 11.5),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
