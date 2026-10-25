import 'package:decimal/decimal.dart';
import 'package:finans_takip/core/calc/fx_rates.dart';
import 'package:finans_takip/core/calc/portfolio_math.dart';
import 'package:finans_takip/core/format/money.dart';
import 'package:finans_takip/data/models/asset.dart';
import 'package:finans_takip/data/models/holding.dart';
import 'package:finans_takip/data/models/quote.dart';
import 'package:flutter_test/flutter_test.dart';

Decimal d(String value) => Decimal.parse(value);

const btc = Asset(
  id: 'btc',
  symbol: 'BTCUSDT',
  name: 'Bitcoin',
  type: AssetType.crypto,
  source: 'Binance',
  delay: DataDelay.live,
  currency: Currency.usd,
  unit: 'BTC',
);

const thyao = Asset(
  id: 'thyao',
  symbol: 'THYAO',
  name: 'Türk Hava Yolları',
  type: AssetType.bist,
  source: 'Bürküt',
  delay: DataDelay.delayed15m,
  currency: Currency.tryLira,
  unit: 'lot',
);

Quote quote(
  String assetId,
  String price, {
  String change = '0',
  double pct = 0,
}) => Quote(
  assetId: assetId,
  price: d(price),
  change24h: d(change),
  changePct24h: pct,
  high24h: d(price),
  low24h: d(price),
  updatedAt: DateTime(2026, 1, 1),
);

final rates = FxRates(base: Currency.tryLira, rates: {Currency.usd: d('40')});

void main() {
  test('an empty portfolio has no positions and no value', () {
    final summary = PortfolioMath.summarize(
      holdings: const [],
      assets: const {},
      quotes: const {},
      rates: rates,
    );

    expect(summary.isEmpty, isTrue);
    expect(summary.totalValue, Decimal.zero);
    expect(summary.dayChangePct, 0);
    expect(summary.allocation, isEmpty);
  });

  test('a foreign currency position is converted into the base currency', () {
    final summary = PortfolioMath.summarize(
      holdings: [
        Holding(
          id: 'h1',
          assetId: 'btc',
          quantity: d('0.5'),
          avgCost: d('80000'),
          currency: Currency.usd,
        ),
      ],
      assets: const {'btc': btc},
      quotes: {'btc': quote('btc', '100000', change: '2000', pct: 2.04)},
      rates: rates,
    );

    // 0.5 BTC · 100.000 $ · 40 ₺/$
    expect(summary.totalValue, d('2000000'));
    expect(summary.totalCost, d('1600000'));
    expect(summary.totalProfit, d('400000'));
    expect(summary.totalProfitPct, closeTo(25, 0.0001));
    // 0.5 · 2.000 $ · 40
    expect(summary.dayChange, d('40000'));
    expect(summary.dayChangePct, closeTo(2.0408, 0.001));
  });

  test('profit is computed per position against the average cost', () {
    final summary = PortfolioMath.summarize(
      holdings: [
        Holding(
          id: 'h1',
          assetId: 'thyao',
          quantity: d('120'),
          avgCost: d('284.60'),
          currency: Currency.tryLira,
        ),
      ],
      assets: const {'thyao': thyao},
      quotes: {'thyao': quote('thyao', '322.50', change: '3.35', pct: 1.05)},
      rates: rates,
    );

    final position = summary.positions.single;
    expect(position.value, d('38700'));
    expect(position.cost, d('34152'));
    expect(position.profit, d('4548'));
    expect(position.profitPct, closeTo(13.316, 0.001));
  });

  test('allocation groups foreign exchange and gold together', () {
    final summary = PortfolioMath.summarize(
      holdings: [
        Holding(
          id: 'h1',
          assetId: 'btc',
          quantity: d('0.1'),
          avgCost: d('90000'),
          currency: Currency.usd,
        ),
        Holding(
          id: 'h2',
          assetId: 'thyao',
          quantity: d('100'),
          avgCost: d('300'),
          currency: Currency.tryLira,
        ),
      ],
      assets: const {'btc': btc, 'thyao': thyao},
      quotes: {'btc': quote('btc', '100000'), 'thyao': quote('thyao', '300')},
      rates: rates,
    );

    // 0.1 · 100.000 · 40 = 400.000 ve 100 · 300 = 30.000
    expect(summary.totalValue, d('430000'));
    final slices = summary.allocation;
    expect(slices.first.group, MarketTab.crypto);
    expect(slices.first.percent, closeTo(93.02, 0.01));
    expect(slices.last.group, MarketTab.bist);
    expect(slices.last.percent, closeTo(6.98, 0.01));
  });

  test('holdings without a quote are skipped instead of crashing', () {
    final summary = PortfolioMath.summarize(
      holdings: [
        Holding(
          id: 'h1',
          assetId: 'btc',
          quantity: d('1'),
          avgCost: d('1'),
          currency: Currency.usd,
        ),
      ],
      assets: const {'btc': btc},
      quotes: const {},
      rates: rates,
    );

    expect(summary.positions, isEmpty);
  });
}
