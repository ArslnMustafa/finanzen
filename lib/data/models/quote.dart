import 'package:decimal/decimal.dart';

/// Latest known price of an asset, plus the numbers the rows and the detail
/// screen show next to it. Mirrors a row of `price_cache`.
class Quote {
  const Quote({
    required this.assetId,
    required this.price,
    required this.change24h,
    required this.changePct24h,
    required this.high24h,
    required this.low24h,
    required this.updatedAt,
    this.sparkline = const <double>[],
  });

  final String assetId;
  final Decimal price;

  /// Absolute change over the last 24 hours, in the asset's own currency.
  final Decimal change24h;

  /// Percentage change over the last 24 hours, e.g. `1.39` for +1,39%.
  final double changePct24h;

  final Decimal high24h;
  final Decimal low24h;

  /// When the cache row was written. Shown as "son güncelleme: …" when the
  /// network is down.
  final DateTime updatedAt;

  /// Small series behind the row sparkline.
  final List<double> sparkline;

  bool get isUp => changePct24h >= 0;
}
