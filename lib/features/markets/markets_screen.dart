import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_search_field.dart';
import '../../core/widgets/asset_row.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/screen_scaffold.dart';
import '../../core/widgets/skeleton.dart';
import '../../data/providers/app_providers.dart';
import '../../theme/app_theme.dart';
import 'widgets/market_tabs.dart';

class MarketsScreen extends ConsumerStatefulWidget {
  const MarketsScreen({super.key, this.focusSearch = false});

  /// Set when the user arrived through the "Ara" shortcut.
  final bool focusSearch;

  @override
  ConsumerState<MarketsScreen> createState() => _MarketsScreenState();
}

class _MarketsScreenState extends ConsumerState<MarketsScreen> {
  late final TextEditingController _controller = TextEditingController(
    text: ref.read(marketQueryProvider),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final assets = ref.watch(marketListProvider);
    final quotes = ref.watch(quotesProvider).value;
    final isLoading = ref.watch(assetsProvider).isLoading;

    return AppScreen(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Text('Piyasalar', style: AppText.screenTitle),
          const SizedBox(height: 14),
          AppSearchField(
            hintText: 'Hisse, coin, fon ara…',
            controller: _controller,
            autofocus: widget.focusSearch,
            onChanged: (value) =>
                ref.read(marketQueryProvider.notifier).set(value),
          ),
          const SizedBox(height: 12),
          MarketTabs(
            selected: ref.watch(marketTabProvider),
            onSelect: (tab) {
              _controller.clear();
              ref.read(marketQueryProvider.notifier).set('');
              ref.read(marketTabProvider.notifier).select(tab);
            },
          ),
          const SizedBox(height: 14),
          const _ColumnHeaders(),
          const SizedBox(height: 6),
          Expanded(
            child: isLoading
                ? const AppCard(child: SkeletonList(count: 6))
                : assets.isEmpty
                ? const EmptyState(
                    icon: LucideIcons.search,
                    title: 'Sonuç yok',
                    message: 'Aradığın varlık listede değil. Farklı bir sembol veya isim dene.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: assets.length,
                    separatorBuilder: (_, _) => const Divider(),
                    itemBuilder: (context, index) {
                      final asset = assets[index];
                      return AssetRow(
                        asset: asset,
                        quote: quotes?[asset.id],
                        showSparkline: true,
                        onTap: () => context.pushNamed(
                          'asset',
                          pathParameters: {'symbol': asset.symbol},
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ColumnHeaders extends StatelessWidget {
  const _ColumnHeaders();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('Varlık', style: AppText.captionSmall),
        const Spacer(),
        Text('Son 24 saat', style: AppText.captionSmall),
        const SizedBox(width: 44),
        Text('Fiyat', style: AppText.captionSmall),
      ],
    );
  }
}
