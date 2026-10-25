import 'package:decimal/decimal.dart';

import '../format/money.dart';

/// Conversion rates into the user's base currency.
///
/// Prices arrive in the currency of their source (crypto in dollars, BIST in
/// lira), so every amount has to be converted before totals can be added up.
class FxRates {
  const FxRates({required this.base, required this.rates});

  final Currency base;

  /// How much one unit of the key currency is worth in [base].
  /// The base currency itself may be omitted; it is always 1.
  final Map<Currency, Decimal> rates;

  Decimal rateOf(Currency currency) {
    if (currency == base) return Decimal.one;
    final rate = rates[currency];
    if (rate == null) {
      throw StateError('${currency.code} için kur bulunamadı');
    }
    return rate;
  }

  /// Converts [amount] from [from] into the base currency.
  Decimal toBase(Decimal amount, Currency from) => amount * rateOf(from);
}
