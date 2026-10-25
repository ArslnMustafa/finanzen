import 'package:decimal/decimal.dart';

import '../../core/format/money.dart';
import '../models/alert_rule.dart';
import '../models/asset.dart';
import '../models/holding.dart';

Decimal _d(String value) => Decimal.parse(value);

/// Static sample data for the first development phase.
///
/// Everything here is replaced by Supabase queries in phase 3; the shapes are
/// already the ones the real tables will return.
abstract final class MockCatalog {
  /// Assets the app knows about, in the order the market list shows them.
  static final List<Asset> assets = [
    // Kripto — Binance public stream, no key needed.
    const Asset(
      id: 'btc',
      symbol: 'BTCUSDT',
      name: 'Bitcoin',
      type: AssetType.crypto,
      source: 'Binance',
      delay: DataDelay.live,
      currency: Currency.usd,
      unit: 'BTC',
    ),
    const Asset(
      id: 'eth',
      symbol: 'ETHUSDT',
      name: 'Ethereum',
      type: AssetType.crypto,
      source: 'Binance',
      delay: DataDelay.live,
      currency: Currency.usd,
      unit: 'ETH',
    ),
    const Asset(
      id: 'sol',
      symbol: 'SOLUSDT',
      name: 'Solana',
      type: AssetType.crypto,
      source: 'Binance',
      delay: DataDelay.live,
      currency: Currency.usd,
      unit: 'SOL',
    ),
    const Asset(
      id: 'avax',
      symbol: 'AVAXUSDT',
      name: 'Avalanche',
      type: AssetType.crypto,
      source: 'Binance',
      delay: DataDelay.live,
      currency: Currency.usd,
      unit: 'AVAX',
    ),
    // BIST — Bürküt, 15 dakika gecikmeli.
    const Asset(
      id: 'thyao',
      symbol: 'THYAO',
      name: 'Türk Hava Yolları',
      type: AssetType.bist,
      source: 'Bürküt',
      delay: DataDelay.delayed15m,
      currency: Currency.tryLira,
      unit: 'lot',
    ),
    const Asset(
      id: 'asels',
      symbol: 'ASELS',
      name: 'Aselsan',
      type: AssetType.bist,
      source: 'Bürküt',
      delay: DataDelay.delayed15m,
      currency: Currency.tryLira,
      unit: 'lot',
    ),
    const Asset(
      id: 'tuprs',
      symbol: 'TUPRS',
      name: 'Tüpraş',
      type: AssetType.bist,
      source: 'Bürküt',
      delay: DataDelay.delayed15m,
      currency: Currency.tryLira,
      unit: 'lot',
    ),
    const Asset(
      id: 'sise',
      symbol: 'SISE',
      name: 'Şişecam',
      type: AssetType.bist,
      source: 'Bürküt',
      delay: DataDelay.delayed15m,
      currency: Currency.tryLira,
      unit: 'lot',
    ),
    // ABD hisseleri — Finnhub.
    const Asset(
      id: 'aapl',
      symbol: 'AAPL',
      name: 'Apple',
      type: AssetType.usStock,
      source: 'Finnhub',
      delay: DataDelay.live,
      currency: Currency.usd,
      unit: 'adet',
    ),
    const Asset(
      id: 'nvda',
      symbol: 'NVDA',
      name: 'NVIDIA',
      type: AssetType.usStock,
      source: 'Finnhub',
      delay: DataDelay.live,
      currency: Currency.usd,
      unit: 'adet',
    ),
    const Asset(
      id: 'msft',
      symbol: 'MSFT',
      name: 'Microsoft',
      type: AssetType.usStock,
      source: 'Finnhub',
      delay: DataDelay.live,
      currency: Currency.usd,
      unit: 'adet',
    ),
    // TEFAS fonları — günde bir kez.
    const Asset(
      id: 'afa',
      symbol: 'AFA',
      name: 'Ak Portföy Yeni Teknolojiler',
      type: AssetType.fund,
      source: 'TEFAS',
      delay: DataDelay.daily,
      currency: Currency.tryLira,
      unit: 'adet',
    ),
    const Asset(
      id: 'ipb',
      symbol: 'IPB',
      name: 'İş Portföy BIST Teknoloji',
      type: AssetType.fund,
      source: 'TEFAS',
      delay: DataDelay.daily,
      currency: Currency.tryLira,
      unit: 'adet',
    ),
    // Döviz ve altın — Bürküt.
    const Asset(
      id: 'usdtry',
      symbol: 'USDTRY',
      name: 'Amerikan Doları',
      type: AssetType.fx,
      source: 'Bürküt',
      delay: DataDelay.delayed15m,
      currency: Currency.tryLira,
      unit: 'USD',
    ),
    const Asset(
      id: 'eurtry',
      symbol: 'EURTRY',
      name: 'Euro',
      type: AssetType.fx,
      source: 'Bürküt',
      delay: DataDelay.delayed15m,
      currency: Currency.tryLira,
      unit: 'EUR',
    ),
    const Asset(
      id: 'gram',
      symbol: 'GRAMALTIN',
      display: 'GRAM',
      name: 'Gram Altın',
      type: AssetType.commodity,
      source: 'Bürküt',
      delay: DataDelay.delayed15m,
      currency: Currency.tryLira,
      unit: 'gram',
    ),
  ];

  /// Same assets, keyed by id.
  static final Map<String, Asset> assetsById = {
    for (final asset in assets) asset.id: asset,
  };

  /// Current price and 24h move per asset id.
  static final Map<String, ({Decimal price, double changePct})> snapshot = {
    'btc': (price: _d('112480.50'), changePct: 2.14),
    'eth': (price: _d('4118.70'), changePct: 1.62),
    'sol': (price: _d('214.36'), changePct: -1.08),
    'avax': (price: _d('38.92'), changePct: 3.47),
    'thyao': (price: _d('322.50'), changePct: 1.05),
    'asels': (price: _d('187.30'), changePct: -0.72),
    'tuprs': (price: _d('168.40'), changePct: 0.44),
    'sise': (price: _d('54.85'), changePct: -1.36),
    'aapl': (price: _d('268.40'), changePct: 0.63),
    'nvda': (price: _d('192.75'), changePct: 2.81),
    'msft': (price: _d('524.10'), changePct: -0.35),
    'afa': (price: _d('3.284600'), changePct: 0.31),
    'ipb': (price: _d('2.917400'), changePct: 0.18),
    'usdtry': (price: _d('48.6042'), changePct: 0.12),
    'eurtry': (price: _d('52.8310'), changePct: 0.26),
    'gram': (price: _d('4286.40'), changePct: 1.86),
  };

  /// Rates used to convert positions into the base currency (TRY).
  static final Map<Currency, Decimal> fxRates = {
    Currency.usd: _d('48.6042'),
    Currency.eur: _d('52.8310'),
  };

  static const List<String> watchlist = ['btc', 'thyao', 'aapl', 'gram', 'afa'];

  static final List<Holding> holdings = [
    Holding(
      id: 'h1',
      assetId: 'btc',
      quantity: _d('0.0150'),
      avgCost: _d('98400.00'),
      currency: Currency.usd,
    ),
    Holding(
      id: 'h2',
      assetId: 'eth',
      quantity: _d('0.1200'),
      avgCost: _d('3860.00'),
      currency: Currency.usd,
    ),
    Holding(
      id: 'h3',
      assetId: 'thyao',
      quantity: _d('120'),
      avgCost: _d('284.60'),
      currency: Currency.tryLira,
    ),
    Holding(
      id: 'h4',
      assetId: 'asels',
      quantity: _d('150'),
      avgCost: _d('196.20'),
      currency: Currency.tryLira,
    ),
    Holding(
      id: 'h5',
      assetId: 'afa',
      quantity: _d('12000'),
      avgCost: _d('2.914000'),
      currency: Currency.tryLira,
    ),
    Holding(
      id: 'h6',
      assetId: 'gram',
      quantity: _d('8'),
      avgCost: _d('3890.00'),
      currency: Currency.tryLira,
    ),
  ];

  static final List<AlertRule> alerts = [
    AlertRule(
      id: 'a1',
      assetId: 'btc',
      condition: AlertCondition.above,
      targetPrice: _d('120000'),
      isActive: true,
    ),
    AlertRule(
      id: 'a2',
      assetId: 'thyao',
      condition: AlertCondition.below,
      targetPrice: _d('300'),
      isActive: true,
    ),
    AlertRule(
      id: 'a3',
      assetId: 'gram',
      condition: AlertCondition.above,
      targetPrice: _d('4500'),
      isActive: false,
    ),
  ];
}
