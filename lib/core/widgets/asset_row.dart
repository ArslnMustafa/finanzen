import 'package:flutter/material.dart';

import '../../data/models/asset.dart';
import '../../data/models/quote.dart';
import '../../theme/app_theme.dart';
import '../format/money.dart';
import 'change_pill.dart';
import 'icon_box.dart';
import 'skeleton.dart';
import 'sparkline.dart';

/// One asset in a list: icon box, name, freshness, price and 24h change.
///
/// Shared by the watchlist on the home screen and the markets list, so both
/// read exactly the same.
class AssetRow extends StatelessWidget {
  const AssetRow({
    super.key,
    required this.asset,
    required this.quote,
    this.onTap,
    this.showSparkline = false,
  });

  final Asset asset;

  /// Null while the price is still loading.
  final Quote? quote;

  final VoidCallback? onTap;
  final bool showSparkline;

  @override
  Widget build(BuildContext context) {
    final quote = this.quote;

    // Wrapped in a transparent Material so the ripple works wherever the
    // row is placed, card or plain container.
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.smallCard),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              IconBox(label: asset.shortCode),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      asset.displaySymbol,
                      style: AppText.listTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${asset.name} · ${asset.delay.label}',
                      style: AppText.captionSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (showSparkline && quote != null) ...[
                const SizedBox(width: 8),
                Sparkline(values: quote.sparkline, isUp: quote.isUp),
                const SizedBox(width: 12),
              ],
              if (quote == null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: const [
                    SkeletonBox(width: 72, height: 13),
                    SizedBox(height: 7),
                    SkeletonBox(width: 46, height: 11),
                  ],
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      Fmt.price(
                        quote.price.toDouble(),
                        currency: asset.currency,
                        decimals: asset.priceDecimals,
                      ),
                      style: AppText.priceRow,
                    ),
                    const SizedBox(height: 2),
                    ChangeText(quote.changePct24h, style: AppText.numberSmall),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
