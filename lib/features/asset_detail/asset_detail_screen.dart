import 'package:collection/collection.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/format/money.dart';
import '../../core/widgets/app_buttons.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/change_pill.dart';
import '../../core/widgets/data_badge.dart';
import '../../core/widgets/screen_scaffold.dart';
import '../../core/widgets/skeleton.dart';
import '../../core/widgets/stat_tile.dart';
import '../../data/models/asset.dart';
import '../../data/models/price_point.dart';
import '../../data/providers/app_providers.dart';
import '../../theme/app_theme.dart';
import '../alerts/widgets/alert_form_sheet.dart';
import '../portfolio/widgets/holding_form_sheet.dart';
import 'widgets/price_chart.dart';
import 'widgets/range_selector.dart';

class AssetDetailScreen extends ConsumerStatefulWidget {
  const AssetDetailScreen({super.key, required this.symbol});

  final String symbol;

  @override
  ConsumerState<AssetDetailScreen> createState() => _AssetDetailScreenState();
}

class _AssetDetailScreenState extends ConsumerState<AssetDetailScreen> {
  ChartRange _range = ChartRange.day;

  @override
  Widget build(BuildContext context) {
    final assets = ref.watch(assetsProvider).value ?? const <Asset>[];
    final asset = assets
        .where((candidate) => candidate.symbol == widget.symbol)
        .firstOrNull;

    if (asset == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: AppScreen(
          child: Column(
            children: [
              _TopBar(title: widget.symbol, subtitle: ''),
              const SizedBox(height: 40),
              Text('Varlık bulunamadı.', style: AppText.body),
            ],
          ),
        ),
      );
    }

    final quote = ref.watch(quoteProvider(asset.id));
    final history = ref.watch(historyProvider((asset.id, _range))).value;
    final inWatchlist = ref.watch(watchlistProvider).contains(asset.id);
    final position = ref
        .watch(portfolioProvider)
        .value
        ?.positions
        .where((p) => p.asset.id == asset.id)
        .firstOrNull;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppScreen(
        child: ListView(
          padding: const EdgeInsets.only(top: 6, bottom: 28),
          children: [
            _TopBar(
              title: asset.displaySymbol,
              subtitle: '${asset.name} · ${asset.type.label}',
              trailing: CircleIconButton(
                icon: LucideIcons.star,
                tooltip: inWatchlist
                    ? 'İzleme listesinden çıkar'
                    : 'İzleme listesine ekle',
                color: inWatchlist ? AppColors.accent : AppColors.textPrimary,
                onPressed: () =>
                    ref.read(watchlistProvider.notifier).toggle(asset.id),
              ),
            ),
            const SizedBox(height: 22),
            if (quote == null)
              const SkeletonBox(width: 190, height: 34, radius: 10)
            else ...[
              Text(
                Fmt.price(
                  quote.price.toDouble(),
                  currency: asset.currency,
                  decimals: asset.priceDecimals,
                ),
                style: AppText.priceHero,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    Fmt.signedPrice(
                      quote.change24h.toDouble(),
                      currency: asset.currency,
                    ),
                    style: AppText.numberBody.copyWith(
                      color: AppColors.forChange(quote.changePct24h),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ChangeText(quote.changePct24h),
                  const SizedBox(width: 8),
                  Text(_range.description, style: AppText.caption),
                ],
              ),
            ],
            const SizedBox(height: 10),
            DataBadge(delay: asset.delay, source: asset.source),
            const SizedBox(height: 16),
            AppCard(
              radius: AppRadius.largeCard,
              padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
              child: Column(
                children: [
                  if (history == null)
                    const SizedBox(
                      height: 180,
                      child: Center(
                        child: SkeletonBox(height: 150, width: 260),
                      ),
                    )
                  else
                    PriceChart(
                      points: history,
                      currency: asset.currency,
                      decimals: asset.priceDecimals,
                    ),
                  const SizedBox(height: 12),
                  RangeSelector(
                    selected: _range,
                    onSelect: (range) => setState(() => _range = range),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: StatTile(
                    label: '24s en yüksek',
                    value: quote == null
                        ? '—'
                        : Fmt.price(
                            quote.high24h.toDouble(),
                            currency: asset.currency,
                            decimals: asset.priceDecimals,
                          ),
                  ),
                ),
                const SizedBox(width: AppSpacing.card),
                Expanded(
                  child: StatTile(
                    label: '24s en düşük',
                    value: quote == null
                        ? '—'
                        : Fmt.price(
                            quote.low24h.toDouble(),
                            currency: asset.currency,
                            decimals: asset.priceDecimals,
                          ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.card),
            Row(
              children: [
                Expanded(
                  child: StatTile(
                    label: 'Sizdeki miktar',
                    value: position == null
                        ? '—'
                        : Fmt.quantity(
                            position.holding.quantity,
                            unit: asset.unit,
                          ),
                    secondary: position == null
                        ? null
                        : Fmt.price(position.value.toDouble()),
                  ),
                ),
                const SizedBox(width: AppSpacing.card),
                Expanded(
                  child: StatTile(
                    label: 'Kâr / zarar',
                    value: position == null
                        ? '—'
                        : Fmt.signedPrice(position.profit.toDouble()),
                    secondary: position == null
                        ? null
                        : Fmt.signedPercent(position.profitPct),
                    valueColor: position == null
                        ? null
                        : AppColors.forChange(position.profitPct),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: GhostButton(
                    label: 'Alarm kur',
                    icon: LucideIcons.bell,
                    onPressed: () =>
                        showAlertFormSheet(context, assetId: asset.id),
                  ),
                ),
                const SizedBox(width: AppSpacing.card),
                Expanded(
                  child: AccentButton(
                    label: 'Portföye ekle',
                    icon: LucideIcons.plus,
                    onPressed: () => showHoldingFormSheet(
                      context,
                      assetId: asset.id,
                      suggestedPrice: quote?.price ?? Decimal.zero,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.title, required this.subtitle, this.trailing});

  final String title;
  final String subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleIconButton(
          icon: LucideIcons.arrowLeft,
          tooltip: 'Geri',
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/markets'),
        ),
        Expanded(
          child: Column(
            children: [
              Text(title, style: AppText.listTitle),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppText.captionSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        trailing ??
            const SizedBox(
              width: AppSpacing.minTapTarget,
              height: AppSpacing.minTapTarget,
            ),
      ],
    );
  }
}
