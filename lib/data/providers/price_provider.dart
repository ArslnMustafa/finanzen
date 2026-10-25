import '../models/asset.dart';
import '../models/price_point.dart';
import '../models/quote.dart';

/// Everything the app needs from a price source.
///
/// Phase 1 ships a mock implementation; phase 3 adds one backed by Supabase
/// (`price_cache` / `price_history`) plus a Binance websocket for crypto.
/// Swapping sources should mean swapping one class, nothing else.
abstract interface class PriceProvider {
  /// Name shown next to the freshness dot, e.g. "Binance".
  String get name;

  /// Assets this source can serve.
  Future<List<Asset>> listAssets();

  /// Latest quote per asset id.
  Future<Map<String, Quote>> fetchQuotes(List<String> assetIds);

  /// Price series for a chart.
  Future<List<PricePoint>> fetchHistory(String assetId, ChartRange range);

  /// Portfolio value over the last seven days, in the base currency.
  Future<List<PricePoint>> fetchPortfolioHistory();

  /// Pushes a new quote map whenever a price moves. Sources without a live
  /// feed can return [Stream.empty].
  Stream<Map<String, Quote>> watchQuotes(List<String> assetIds);
}
