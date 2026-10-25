import '../../core/format/money.dart';

/// Kind of tradable thing the app can show.
enum AssetType {
  crypto('crypto', 'Kripto'),
  bist('bist', 'BIST'),
  usStock('us_stock', 'ABD'),
  fund('fund', 'Fon'),
  fx('fx', 'Döviz'),
  commodity('commodity', 'Altın');

  const AssetType(this.code, this.label);

  /// Value stored in Postgres (`assets.type`).
  final String code;

  /// Turkish label shown in the interface.
  final String label;

  static AssetType fromCode(String code) =>
      AssetType.values.firstWhere((t) => t.code == code);
}

/// How fresh the price of an asset is. The design asks for this to be visible
/// on every row so nobody mistakes delayed data for a live quote.
enum DataDelay {
  live('live', 'Canlı'),
  delayed15m('delayed_15m', '15 dk gecikmeli'),
  daily('daily', 'Günlük');

  const DataDelay(this.code, this.label);

  final String code;
  final String label;

  static DataDelay fromCode(String code) =>
      DataDelay.values.firstWhere((d) => d.code == code);
}

/// A single tradable asset. Mirrors the `assets` table.
class Asset {
  const Asset({
    required this.id,
    required this.symbol,
    required this.name,
    required this.type,
    required this.source,
    required this.delay,
    required this.currency,
    this.unit,
    this.display,
  });

  final String id;

  /// Ticker as the source knows it: `BTCUSDT`, `THYAO`, `AAPL`.
  final String symbol;

  /// Full name shown under the ticker.
  final String name;

  final AssetType type;

  /// Where the price comes from: `Binance`, `Finnhub`, `Bürküt`, `TEFAS`.
  final String source;

  final DataDelay delay;

  /// Currency the price is quoted in.
  final Currency currency;

  /// Unit used when showing a quantity: `BTC`, `lot`, `adet`, `gram`.
  final String? unit;

  /// Shorter ticker for the interface where the source symbol is unwieldy
  /// (`GRAMALTIN` → `GRAM`). Defaults to the symbol without its quote
  /// currency suffix.
  final String? display;

  /// Ticker as the interface shows it.
  String get displaySymbol =>
      display ?? symbol.replaceAll(RegExp(r'USDT$'), '');

  /// Decimals a price of this asset should be shown with; null means the
  /// formatter decides from the magnitude.
  int? get priceDecimals => switch (type) {
    AssetType.fund => 6,
    AssetType.fx => 4,
    _ => null,
  };

  /// Short label for the square icon box, at most four characters.
  String get shortCode {
    final base = symbol.replaceAll(RegExp(r'(USDT|TRY)$'), '');
    final cleaned = base.isEmpty ? symbol : base;
    return cleaned.length <= 4 ? cleaned : cleaned.substring(0, 4);
  }

  /// `Kripto · Canlı`
  String get subtitle => '${type.label} · ${delay.label}';
}

/// Tabs of the markets screen. Foreign exchange and gold share one tab, so a
/// tab maps to one or more [AssetType]s.
enum MarketTab {
  crypto('Kripto', {AssetType.crypto}),
  bist('BIST', {AssetType.bist}),
  us('ABD', {AssetType.usStock}),
  funds('Fonlar', {AssetType.fund}),
  fxGold('Döviz & Altın', {AssetType.fx, AssetType.commodity});

  const MarketTab(this.label, this.types);

  final String label;
  final Set<AssetType> types;

  static MarketTab forType(AssetType type) =>
      MarketTab.values.firstWhere((tab) => tab.types.contains(type));
}
