import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/widgets/app_buttons.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/asset_row.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/screen_scaffold.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/skeleton.dart';
import '../../data/providers/app_providers.dart';
import '../../theme/app_theme.dart';
import '../alerts/widgets/alert_form_sheet.dart';
import '../auth/auth_providers.dart';
import '../portfolio/widgets/holding_form_sheet.dart';
import 'widgets/portfolio_value_card.dart';
import 'widgets/quick_actions.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfolio = ref.watch(portfolioProvider);
    final history = ref.watch(portfolioHistoryProvider).value ?? const [];
    final watchlist = ref.watch(watchlistAssetsProvider);
    final quotes = ref.watch(quotesProvider).value;

    return AppScreen(
      child: ListView(
        padding: const EdgeInsets.only(top: 8, bottom: 28),
        children: [
          _Greeting(name: ref.watch(userNameProvider)),
          const SizedBox(height: 18),
          PortfolioValueCard(summary: portfolio.value, history: history),
          const SizedBox(height: AppSpacing.section),
          QuickActions(
            onAddHolding: () => showHoldingFormSheet(context),
            onCreateAlert: () => showAlertFormSheet(context),
            onMarkets: () => const MarketsDestination().go(context),
            onSearch: () =>
                const MarketsDestination(focusSearch: true).go(context),
          ),
          const SizedBox(height: AppSpacing.section),
          SectionHeader(
            title: 'İzleme listem',
            actionLabel: 'Tümü',
            onAction: () => const MarketsDestination().go(context),
          ),
          const SizedBox(height: 4),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: watchlist.isEmpty
                ? EmptyState(
                    icon: LucideIcons.star,
                    title: 'İzleme listen boş',
                    message: 'Piyasalardan bir varlık seçip yıldıza dokunarak buraya ekleyebilirsin.',
                    actionLabel: 'Piyasalara git',
                    onAction: () => const MarketsDestination().go(context),
                  )
                : Column(
                    children: [
                      for (var i = 0; i < watchlist.length; i++) ...[
                        if (i > 0) const Divider(),
                        AssetRow(
                          asset: watchlist[i],
                          quote: quotes?[watchlist[i].id],
                          onTap: () => context.pushNamed(
                            'asset',
                            pathParameters: {'symbol': watchlist[i].symbol},
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
          if (quotes == null && watchlist.isEmpty) ...[
            const SizedBox(height: 12),
            const AppCard(child: SkeletonList()),
          ],
        ],
      ),
    );
  }
}

/// Jumping to the markets tab, optionally with the search box focused.
class MarketsDestination {
  const MarketsDestination({this.focusSearch = false});

  final bool focusSearch;

  void go(BuildContext context) =>
      context.go(focusSearch ? '/markets?ara=1' : '/markets');
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(greetingFor(DateTime.now()), style: AppText.caption),
              const SizedBox(height: 2),
              Text(name, style: AppText.screenTitle),
            ],
          ),
        ),
        CircleIconButton(
          icon: LucideIcons.bell,
          tooltip: 'Bildirimler',
          onPressed: () => context.go('/alerts'),
        ),
        const SizedBox(width: 8),
        CircleIconButton(
          icon: LucideIcons.settings,
          tooltip: 'Ayarlar',
          onPressed: () => context.push('/ayarlar'),
        ),
      ],
    );
  }
}
