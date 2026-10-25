import '../models/asset.dart';
import '../models/price_point.dart';
import '../models/quote.dart';
import '../providers/price_provider.dart';

/// Reads market data through whichever [PriceProvider] is configured.
class MarketRepository {
  const MarketRepository(this._source);

  final PriceProvider _source;

  String get sourceName => _source.name;

  Future<List<Asset>> assets() => _source.listAssets();

  Stream<Map<String, Quote>> watchQuotes(List<String> assetIds) =>
      _source.watchQuotes(assetIds);

  Future<List<PricePoint>> history(String assetId, ChartRange range) =>
      _source.fetchHistory(assetId, range);

  Future<List<PricePoint>> portfolioHistory() =>
      _source.fetchPortfolioHistory();

  /// Filters by tab and free text. The query matches the ticker as well as
  /// the name, case-insensitively and ignoring Turkish casing quirks.
  static List<Asset> filter(
    List<Asset> assets, {
    MarketTab? tab,
    String query = '',
  }) {
    final needle = _fold(query);
    return assets.where((asset) {
      if (tab != null && !tab.types.contains(asset.type)) return false;
      if (needle.isEmpty) return true;
      return _fold(asset.symbol).contains(needle) ||
          _fold(asset.name).contains(needle);
    }).toList();
  }

  static String _fold(String value) => value
      .toLowerCase()
      .replaceAll('ı', 'i')
      .replaceAll('İ', 'i')
      .replaceAll('ş', 's')
      .replaceAll('ğ', 'g')
      .replaceAll('ü', 'u')
      .replaceAll('ö', 'o')
      .replaceAll('ç', 'c')
      .trim();
}
