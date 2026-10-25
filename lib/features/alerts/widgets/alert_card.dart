import 'package:flutter/material.dart';

import '../../../core/format/money.dart';
import '../../../core/widgets/app_card.dart';
import '../../../data/models/alert_rule.dart';
import '../../../data/models/asset.dart';
import '../../../data/models/quote.dart';
import '../../../theme/app_theme.dart';

/// One price alert: the condition in words, how far the price is from the
/// target, and a switch to arm or disarm it.
class AlertCard extends StatelessWidget {
  const AlertCard({
    super.key,
    required this.alert,
    required this.asset,
    required this.quote,
    required this.onToggle,
    this.onDelete,
  });

  final AlertRule alert;
  final Asset asset;
  final Quote? quote;
  final ValueChanged<bool> onToggle;
  final VoidCallback? onDelete;

  String get _title {
    final symbol = asset.symbol.replaceAll(RegExp(r'USDT$'), '');
    final target = Fmt.price(
      alert.targetPrice.toDouble(),
      currency: asset.currency,
    );
    return '$symbol $target ${alert.condition.label}';
  }

  String _subtitle() {
    final quote = this.quote;
    if (quote == null) return asset.name;
    final current = Fmt.price(
      quote.price.toDouble(),
      currency: asset.currency,
      decimals: asset.priceDecimals,
    );
    final target = alert.targetPrice.toDouble();
    final price = quote.price.toDouble();
    if (price == 0) return 'Şu an $current';
    final distance = ((target - price) / price * 100).abs();
    return 'Şu an $current · hedefe ${Fmt.percent(distance, decimals: 1)} var';
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _title,
                  style: AppText.listTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  _subtitle(),
                  style: AppText.captionSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (onDelete != null)
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.close_rounded, size: 18),
              color: AppColors.textSecondary,
              tooltip: 'Alarmı sil',
              constraints: const BoxConstraints(
                minWidth: AppSpacing.minTapTarget,
                minHeight: AppSpacing.minTapTarget,
              ),
            ),
          Semantics(
            label: '$_title alarmı',
            toggled: alert.isActive,
            child: Switch(value: alert.isActive, onChanged: onToggle),
          ),
        ],
      ),
    );
  }
}
