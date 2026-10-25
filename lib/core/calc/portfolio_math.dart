import 'package:decimal/decimal.dart';

import '../../data/models/asset.dart';
import '../../data/models/holding.dart';
import '../../data/models/quote.dart';
import '../format/money.dart';
import 'fx_rates.dart';

/// One holding valued at the current price, in the user's base currency.
class PortfolioPosition {
  const PortfolioPosition({
    required this.asset,
    required this.holding,
    required this.quote,
    required this.value,
    required this.cost,
    required this.dayChange,
  });

  final Asset asset;
  final Holding holding;
  final Quote quote;

  /// Current worth of the position in the base currency.
  final Decimal value;

  /// What the position cost, in the base currency.
  final Decimal cost;

  /// How much the position moved in the last 24 hours, in the base currency.
  final Decimal dayChange;

  /// Profit or loss against the average cost.
  Decimal get profit => value - cost;

  /// Profit as a percentage of the cost; zero when the cost is zero.
  double get profitPct {
    if (cost == Decimal.zero) return 0;
    return (profit.toDouble() / cost.toDouble()) * 100;
  }
}

/// Totals across every position.
class PortfolioSummary {
  const PortfolioSummary({
    required this.positions,
    required this.totalValue,
    required this.totalCost,
    required this.dayChange,
    required this.baseCurrency,
  });

  PortfolioSummary.empty(this.baseCurrency)
    : positions = const [],
      totalValue = Decimal.zero,
      totalCost = Decimal.zero,
      dayChange = Decimal.zero;

  final List<PortfolioPosition> positions;
  final Decimal totalValue;
  final Decimal totalCost;
  final Decimal dayChange;
  final Currency baseCurrency;

  Decimal get totalProfit => totalValue - totalCost;

  double get totalProfitPct {
    if (totalCost == Decimal.zero) return 0;
    return (totalProfit.toDouble() / totalCost.toDouble()) * 100;
  }

  /// Day change as a percentage of yesterday's value.
  double get dayChangePct {
    final previous = totalValue - dayChange;
    if (previous == Decimal.zero) return 0;
    return (dayChange.toDouble() / previous.toDouble()) * 100;
  }

  bool get isEmpty => positions.isEmpty;

  /// Share of the portfolio per market group, in percent, largest first.
  /// Groups with no holdings are left out.
  List<AllocationSlice> get allocation {
    if (totalValue == Decimal.zero) return const [];
    final byGroup = <MarketTab, Decimal>{};
    for (final position in positions) {
      byGroup.update(
        MarketTab.forType(position.asset.type),
        (current) => current + position.value,
        ifAbsent: () => position.value,
      );
    }
    final slices =
        byGroup.entries
            .map(
              (entry) => AllocationSlice(
                group: entry.key,
                value: entry.value,
                percent: (entry.value.toDouble() / totalValue.toDouble()) * 100,
              ),
            )
            .toList()
          ..sort((a, b) => b.percent.compareTo(a.percent));
    return slices;
  }
}

/// A wedge of the allocation donut.
class AllocationSlice {
  const AllocationSlice({
    required this.group,
    required this.value,
    required this.percent,
  });

  final MarketTab group;
  final Decimal value;
  final double percent;
}

/// Turns holdings plus quotes into a valued portfolio.
///
/// Everything is computed with [Decimal]; doubles only appear where a
/// percentage is needed for display.
abstract final class PortfolioMath {
  static PortfolioSummary summarize({
    required List<Holding> holdings,
    required Map<String, Asset> assets,
    required Map<String, Quote> quotes,
    required FxRates rates,
  }) {
    final positions = <PortfolioPosition>[];
    var totalValue = Decimal.zero;
    var totalCost = Decimal.zero;
    var dayChange = Decimal.zero;

    for (final holding in holdings) {
      final asset = assets[holding.assetId];
      final quote = quotes[holding.assetId];
      if (asset == null || quote == null) continue;

      final value = rates.toBase(
        holding.quantity * quote.price,
        asset.currency,
      );
      final cost = rates.toBase(
        holding.quantity * holding.avgCost,
        holding.currency,
      );
      final change = rates.toBase(
        holding.quantity * quote.change24h,
        asset.currency,
      );

      positions.add(
        PortfolioPosition(
          asset: asset,
          holding: holding,
          quote: quote,
          value: value,
          cost: cost,
          dayChange: change,
        ),
      );

      totalValue += value;
      totalCost += cost;
      dayChange += change;
    }

    positions.sort((a, b) => b.value.compareTo(a.value));

    return PortfolioSummary(
      positions: positions,
      totalValue: totalValue,
      totalCost: totalCost,
      dayChange: dayChange,
      baseCurrency: rates.base,
    );
  }
}
