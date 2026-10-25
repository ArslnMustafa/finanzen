import 'dart:async';
import 'dart:math';

import 'package:decimal/decimal.dart';

import '../../core/calc/fx_rates.dart';
import '../../core/calc/portfolio_math.dart';
import '../../core/format/money.dart';
import '../mock/mock_catalog.dart';
import '../models/asset.dart';
import '../models/price_point.dart';
import '../models/quote.dart';
import 'price_provider.dart';

/// In-memory price source used until the Supabase backend exists.
///
/// The series are a seeded random walk, so the same asset always draws the
/// same chart and screenshots stay comparable between runs.
class MockPriceProvider implements PriceProvider {
  MockPriceProvider({
    this.latency = const Duration(milliseconds: 350),
    this.ticking = true,
  });

  /// Fake network delay, so loading skeletons are visible during development.
  final Duration latency;

  /// When false the stream emits once and closes, which is what tests want.
  final bool ticking;

  @override
  String get name => 'Örnek veri';

  @override
  Future<List<Asset>> listAssets() async {
    await Future<void>.delayed(latency);
    return MockCatalog.assets;
  }

  @override
  Future<Map<String, Quote>> fetchQuotes(List<String> assetIds) async {
    await Future<void>.delayed(latency);
    return _quotes(assetIds);
  }

  @override
  Future<List<PricePoint>> fetchHistory(
    String assetId,
    ChartRange range,
  ) async {
    await Future<void>.delayed(latency);
    return _series(assetId, range);
  }

  @override
  Future<List<PricePoint>> fetchPortfolioHistory() async {
    await Future<void>.delayed(latency);
    // The series has to end on the value the portfolio screen computes, so
    // it is derived from the same holdings and quotes.
    final summary = PortfolioMath.summarize(
      holdings: MockCatalog.holdings,
      assets: MockCatalog.assetsById,
      quotes: _quotes(MockCatalog.assetsById.keys.toList()),
      rates: FxRates(base: Currency.tryLira, rates: MockCatalog.fxRates),
    );
    final end = summary.totalValue.toDouble();
    // Roughly three times today's move over the week.
    final start = end / (1 + (summary.dayChangePct * 3) / 100);

    final now = DateTime.now();
    final random = Random(7);
    return List.generate(8, (i) {
      final progress = i / 7;
      final noise = i == 7 ? 0 : (random.nextDouble() - 0.5) * (end * 0.012);
      final value = start + (end - start) * progress + noise;
      return PricePoint(
        now.subtract(Duration(days: 7 - i)),
        double.parse(value.toStringAsFixed(2)),
      );
    });
  }

  @override
  Stream<Map<String, Quote>> watchQuotes(List<String> assetIds) async* {
    yield _quotes(assetIds);
    if (!ticking) return;
    var tick = 0;
    await for (final _ in Stream<void>.periodic(const Duration(seconds: 5))) {
      tick++;
      yield _quotes(assetIds, tick: tick);
    }
  }

  // ---------------------------------------------------------------------

  Map<String, Quote> _quotes(List<String> assetIds, {int tick = 0}) {
    final now = DateTime.now();
    final result = <String, Quote>{};
    for (final id in assetIds) {
      final snapshot = MockCatalog.snapshot[id];
      final asset = MockCatalog.assetsById[id];
      if (snapshot == null || asset == null) continue;

      // Only live sources move between ticks; delayed and daily ones sit
      // still, which is also what the user is told on screen.
      final drift = asset.delay == DataDelay.live && tick > 0
          ? _drift(id, tick)
          : Decimal.zero;
      final price = snapshot.price + drift;
      final previous = _previousClose(snapshot.price, snapshot.changePct);
      final change = price - previous;
      final changePct = previous == Decimal.zero
          ? 0.0
          : (change.toDouble() / previous.toDouble()) * 100;
      final series = _series(id, ChartRange.day);

      result[id] = Quote(
        assetId: id,
        price: price,
        change24h: change,
        changePct24h: changePct,
        high24h: _round(_extreme(series, high: true), snapshot.price),
        low24h: _round(_extreme(series, high: false), snapshot.price),
        updatedAt: now,
        sparkline: _sample(series, 24),
      );
    }
    return result;
  }

  /// Small, deterministic movement so live assets visibly tick.
  Decimal _drift(String assetId, int tick) {
    final random = Random(assetId.hashCode ^ tick);
    final base = MockCatalog.snapshot[assetId]!.price.toDouble();
    final delta = (random.nextDouble() - 0.5) * base * 0.0012;
    return Decimal.parse(delta.toStringAsFixed(_scaleFor(base)));
  }

  Decimal _previousClose(Decimal price, double changePct) {
    final previous = price.toDouble() / (1 + changePct / 100);
    return Decimal.parse(previous.toStringAsFixed(_scaleFor(price.toDouble())));
  }

  int _scaleFor(double value) => value.abs() >= 100 ? 2 : 6;

  Decimal _round(double value, Decimal reference) =>
      Decimal.parse(value.toStringAsFixed(_scaleFor(reference.toDouble())));

  double _extreme(List<PricePoint> series, {required bool high}) {
    var result = series.first.price;
    for (final point in series) {
      if (high ? point.price > result : point.price < result) {
        result = point.price;
      }
    }
    return result;
  }

  List<double> _sample(List<PricePoint> series, int count) {
    if (series.length <= count) return [for (final p in series) p.price];
    final step = series.length / count;
    return List.generate(
      count,
      (i) => series[(i * step).floor().clamp(0, series.length - 1)].price,
    );
  }

  /// Seeded random walk that ends on the current price.
  List<PricePoint> _series(String assetId, ChartRange range) {
    final snapshot = MockCatalog.snapshot[assetId];
    if (snapshot == null) return const [];

    final end = snapshot.price.toDouble();
    final points = switch (range) {
      ChartRange.hour => 60,
      ChartRange.day => 96,
      ChartRange.week => 84,
      ChartRange.month => 90,
      ChartRange.year => 120,
      ChartRange.all => 150,
    };
    final span = switch (range) {
      ChartRange.hour => const Duration(hours: 1),
      ChartRange.day => const Duration(days: 1),
      ChartRange.week => const Duration(days: 7),
      ChartRange.month => const Duration(days: 30),
      ChartRange.year => const Duration(days: 365),
      ChartRange.all => const Duration(days: 1095),
    };
    // Longer ranges start further away from today's price.
    final totalChange = switch (range) {
      ChartRange.hour => snapshot.changePct / 6,
      ChartRange.day => snapshot.changePct,
      ChartRange.week => snapshot.changePct * 2.4,
      ChartRange.month => snapshot.changePct * 4.1,
      ChartRange.year => snapshot.changePct * 9.3,
      ChartRange.all => snapshot.changePct * 14.7,
    };
    final start = end / (1 + totalChange / 100);
    final volatility = switch (range) {
      ChartRange.hour => 0.0016,
      ChartRange.day => 0.0035,
      ChartRange.week => 0.006,
      _ => 0.011,
    };

    final random = Random(assetId.hashCode ^ range.index);
    final walk = <double>[1];
    for (var i = 1; i < points; i++) {
      final step = (random.nextDouble() - 0.5) * 2 * volatility;
      walk.add(walk.last * (1 + step));
    }
    // Remove the drift the walk picked up, then lay the real trend on top.
    final correction = walk.last;
    final now = DateTime.now();
    final interval = span ~/ (points - 1);

    return List.generate(points, (i) {
      final progress = i / (points - 1);
      final detrended = walk[i] / pow(correction, progress);
      final value = start * pow(end / start, progress) * detrended;
      return PricePoint(
        now.subtract(interval * (points - 1 - i)),
        double.parse(value.toStringAsFixed(end >= 100 ? 2 : 6)),
      );
    });
  }
}
