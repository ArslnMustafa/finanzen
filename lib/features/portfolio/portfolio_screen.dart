import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/widgets/app_buttons.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/screen_scaffold.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/skeleton.dart';
import '../../data/providers/app_providers.dart';
import '../../theme/app_theme.dart';
import '../alerts/widgets/alert_card.dart';
import '../alerts/widgets/alert_form_sheet.dart';
import 'widgets/allocation_card.dart';
import 'widgets/holding_form_sheet.dart';
import 'widgets/position_row.dart';

class PortfolioScreen extends ConsumerWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfolio = ref.watch(portfolioProvider).value;
    final alerts = ref.watch(alertsProvider);
    final assetsById = ref.watch(assetsByIdProvider);
    final quotes = ref.watch(quotesProvider).value;

    return AppScreen(
      child: ListView(
        padding: const EdgeInsets.only(top: 10, bottom: 28),
        children: [
          Row(
            children: [
              Expanded(child: Text('Portföy', style: AppText.screenTitle)),
              PillButton(
                label: 'Ekle',
                icon: LucideIcons.plus,
                onPressed: () => showHoldingFormSheet(context),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (portfolio == null)
            const AppCard(child: SkeletonList(count: 3))
          else if (portfolio.isEmpty)
            AppCard(
              radius: AppRadius.largeCard,
              child: EmptyState(
                icon: LucideIcons.wallet,
                title: 'Portföyün boş',
                message: 'Sahip olduğun varlıkları ekle, değerini ve kâr/zararını burada takip et.',
                actionLabel: 'Varlık ekle',
                onAction: () => showHoldingFormSheet(context),
              ),
            )
          else ...[
            AllocationCard(slices: portfolio.allocation),
            const SizedBox(height: AppSpacing.section),
            const SectionHeader(title: 'Varlıklarım'),
            const SizedBox(height: 4),
            AppCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              child: Column(
                children: [
                  for (var i = 0; i < portfolio.positions.length; i++) ...[
                    if (i > 0) const Divider(),
                    PositionRow(
                      position: portfolio.positions[i],
                      onTap: () => context.pushNamed(
                        'asset',
                        pathParameters: {
                          'symbol': portfolio.positions[i].asset.symbol,
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.section),
          SectionHeader(
            title: 'Fiyat alarmları',
            actionLabel: 'Tümü',
            onAction: () => context.go('/alerts'),
          ),
          const SizedBox(height: 4),
          if (alerts.isEmpty)
            AppCard(
              child: EmptyState(
                icon: LucideIcons.bell,
                title: 'Alarm yok',
                message:
                    'Bir fiyat hedefi belirle, yerine gelince haber verelim.',
                actionLabel: 'Alarm kur',
                onAction: () => showAlertFormSheet(context),
              ),
            )
          else
            for (final alert in alerts.take(3)) ...[
              if (alert != alerts.first)
                const SizedBox(height: AppSpacing.card),
              if (assetsById[alert.assetId] != null)
                AlertCard(
                  alert: alert,
                  asset: assetsById[alert.assetId]!,
                  quote: quotes?[alert.assetId],
                  onToggle: (value) => ref
                      .read(alertsProvider.notifier)
                      .setActive(alert.id, isActive: value),
                ),
            ],
        ],
      ),
    );
  }
}
