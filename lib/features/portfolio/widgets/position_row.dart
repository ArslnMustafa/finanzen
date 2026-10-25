import 'package:flutter/material.dart';

import '../../../core/calc/portfolio_math.dart';
import '../../../core/format/money.dart';
import '../../../core/widgets/icon_box.dart';
import '../../../theme/app_theme.dart';

/// One holding: name, quantity, current value and profit.
class PositionRow extends StatelessWidget {
  const PositionRow({super.key, required this.position, this.onTap});

  final PortfolioPosition position;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final asset = position.asset;
    // Wrapped in a transparent Material so the ripple works wherever the
    // row is placed, card or plain container.
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.smallCard),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 11),
          child: Row(
            children: [
              IconBox(label: asset.shortCode),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      asset.name,
                      style: AppText.listTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      Fmt.quantity(position.holding.quantity, unit: asset.unit),
                      style: AppText.numberSmall,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    Fmt.price(position.value.toDouble()),
                    style: AppText.priceRow,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${Fmt.signedPrice(position.profit.toDouble(), decimals: 0)}'
                    ' · ${Fmt.signedPercent(position.profitPct)}',
                    style: AppText.numberSmall.copyWith(
                      color: AppColors.forChange(position.profitPct),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
