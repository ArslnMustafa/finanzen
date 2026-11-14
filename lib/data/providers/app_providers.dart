import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/calc/fx_rates.dart';
import '../../core/calc/portfolio_math.dart';
import '../../core/format/money.dart';
import '../mock/mock_catalog.dart';
import '../models/alert_rule.dart';
import '../models/asset.dart';
import '../models/holding.dart';
import '../models/price_point.dart';
import '../models/quote.dart';
import '../repositories/market_repository.dart';
import '../repositories/user_data_repository.dart';
import 'mock_price_provider.dart';
import 'price_provider.dart';

/// The active price source. Phase 3 swaps this one line for the Supabase
/// backed provider and the rest of the app keeps working.
final priceSourceProvider = Provider<PriceProvider>((ref) {
  final source = MockPriceProvider();
  return source;
});

final marketRepositoryProvider = Provider<MarketRepository>(
  (ref) => MarketRepository(ref.watch(priceSourceProvider)),
);

final userDataRepositoryProvider = Provider<UserDataRepository>(
  (ref) => MemoryUserDataRepository(),
);

/// Every asset the app can show.
final assetsProvider = FutureProvider<List<Asset>>(
  (ref) => ref.watch(marketRepositoryProvider).assets(),
);

final assetsByIdProvider = Provider<Map<String, Asset>>((ref) {
  final assets = ref.watch(assetsProvider).value ?? const <Asset>[];
  return {for (final asset in assets) asset.id: asset};
});

/// Live quotes for every known asset.
final quotesProvider = StreamProvider<Map<String, Quote>>((ref) async* {
  final assets = await ref.watch(assetsProvider.future);
  yield* ref.watch(marketRepositoryProvider).watchQuotes([
    for (final asset in assets) asset.id,
  ]);
});

/// Quote of a single asset, or null while it is still loading.
final quoteProvider = Provider.family<Quote?, String>(
  (ref, assetId) => ref.watch(quotesProvider).value?[assetId],
);

/// Price series for a chart.
final historyProvider =
    FutureProvider.family<List<PricePoint>, (String, ChartRange)>(
      (ref, args) =>
          ref.watch(marketRepositoryProvider).history(args.$1, args.$2),
    );

/// Portfolio value over the last seven days.
final portfolioHistoryProvider = FutureProvider<List<PricePoint>>(
  (ref) => ref.watch(marketRepositoryProvider).portfolioHistory(),
);

/// Conversion rates into the base currency. Phase 3 derives these from the
/// live FX quotes instead of the mock table.
final fxRatesProvider = Provider<FxRates>(
  (ref) => FxRates(base: Currency.tryLira, rates: MockCatalog.fxRates),
);

// --- User data ---------------------------------------------------------

class WatchlistNotifier extends Notifier<List<String>> {
  @override
  List<String> build() => ref.watch(userDataRepositoryProvider).watchlist();

  bool contains(String assetId) => state.contains(assetId);

  void toggle(String assetId) {
    final next = state.contains(assetId)
        ? state.where((id) => id != assetId).toList()
        : [...state, assetId];
    ref.read(userDataRepositoryProvider).setWatchlist(next);
    state = next;
  }
}

final watchlistProvider = NotifierProvider<WatchlistNotifier, List<String>>(
  WatchlistNotifier.new,
);

class HoldingsNotifier extends Notifier<List<Holding>> {
  @override
  List<Holding> build() => ref.watch(userDataRepositoryProvider).holdings();

  void add(Holding holding) => _save([...state, holding]);

  void remove(String holdingId) =>
      _save(state.where((h) => h.id != holdingId).toList());

  void _save(List<Holding> next) {
    ref.read(userDataRepositoryProvider).setHoldings(next);
    state = next;
  }
}

final holdingsProvider = NotifierProvider<HoldingsNotifier, List<Holding>>(
  HoldingsNotifier.new,
);

class AlertsNotifier extends Notifier<List<AlertRule>> {
  @override
  List<AlertRule> build() => ref.watch(userDataRepositoryProvider).alerts();

  void add(AlertRule alert) => _save([...state, alert]);

  void remove(String alertId) =>
      _save(state.where((a) => a.id != alertId).toList());

  void setActive(String alertId, {required bool isActive}) => _save([
    for (final alert in state)
      if (alert.id == alertId) alert.copyWith(isActive: isActive) else alert,
  ]);

  void _save(List<AlertRule> next) {
    ref.read(userDataRepositoryProvider).setAlerts(next);
    state = next;
  }
}

final alertsProvider = NotifierProvider<AlertsNotifier, List<AlertRule>>(
  AlertsNotifier.new,
);

// --- Derived -----------------------------------------------------------

/// The valued portfolio: holdings priced with the latest quotes.
final portfolioProvider = Provider<AsyncValue<PortfolioSummary>>((ref) {
  final assets = ref.watch(assetsProvider);
  final quotes = ref.watch(quotesProvider);
  final holdings = ref.watch(holdingsProvider);
  final rates = ref.watch(fxRatesProvider);

  if (assets.hasError) {
    return AsyncValue.error(assets.error!, assets.stackTrace!);
  }
  if (quotes.hasError) {
    return AsyncValue.error(quotes.error!, quotes.stackTrace!);
  }
  final assetList = assets.value;
  final quoteMap = quotes.value;
  if (assetList == null || quoteMap == null) {
    return const AsyncValue.loading();
  }

  return AsyncValue.data(
    PortfolioMath.summarize(
      holdings: holdings,
      assets: {for (final asset in assetList) asset.id: asset},
      quotes: quoteMap,
      rates: rates,
    ),
  );
});

/// Assets on the watchlist, in the order the user put them.
final watchlistAssetsProvider = Provider<List<Asset>>((ref) {
  final byId = ref.watch(assetsByIdProvider);
  return [
    for (final id in ref.watch(watchlistProvider))
      if (byId[id] != null) byId[id]!,
  ];
});

// --- Markets screen state ---------------------------------------------

class MarketTabNotifier extends Notifier<MarketTab> {
  @override
  MarketTab build() => MarketTab.crypto;

  void select(MarketTab tab) => state = tab;
}

final marketTabProvider = NotifierProvider<MarketTabNotifier, MarketTab>(
  MarketTabNotifier.new,
);

class MarketQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void set(String query) => state = query;
}

final marketQueryProvider = NotifierProvider<MarketQueryNotifier, String>(
  MarketQueryNotifier.new,
);

/// Market list after the tab and the search box have had their say.
/// A search looks across every tab, which is what people expect.
final marketListProvider = Provider<List<Asset>>((ref) {
  final assets = ref.watch(assetsProvider).value ?? const <Asset>[];
  final query = ref.watch(marketQueryProvider);
  final tab = ref.watch(marketTabProvider);
  return MarketRepository.filter(
    assets,
    tab: query.isEmpty ? tab : null,
    query: query,
  );
});

// --- Greeting ----------------------------------------------------------

/// "Günaydın" / "İyi günler" / "İyi akşamlar" / "İyi geceler".
String greetingFor(DateTime now) {
  final hour = now.hour;
  if (hour < 6) return 'İyi geceler';
  if (hour < 12) return 'Günaydın';
  if (hour < 18) return 'İyi günler';
  return 'İyi akşamlar';
}
