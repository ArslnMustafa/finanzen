import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';

/// Currencies the app can display. The symbol is placed in front of the
/// amount (`₺248.360,42`), which is what the design asks for even though the
/// Turkish locale would normally put it behind.
enum Currency {
  tryLira('TRY', '₺'),
  usd('USD', '\$'),
  eur('EUR', '€');

  const Currency(this.code, this.symbol);

  final String code;
  final String symbol;

  static Currency fromCode(String code) => Currency.values.firstWhere(
    (c) => c.code == code.toUpperCase(),
    orElse: () => Currency.tryLira,
  );
}

const _locale = 'tr_TR';

/// Number, money and percentage formatting, all in Turkish locale.
///
/// Every signed value is rendered with an explicit `+` or `−` so that the
/// direction is readable without relying on colour.
abstract final class Fmt {
  static const _plus = '+';
  static const _minus = '−'; // U+2212 MINUS SIGN

  static NumberFormat _pattern(int decimals) => NumberFormat(
    decimals == 0 ? '#,##0' : '#,##0.${'0' * decimals}',
    _locale,
  );

  /// How many decimals a price deserves: large numbers get two, small ones
  /// (think 0,00002341 DOGE) get enough digits to stay meaningful.
  static int decimalsFor(num value) {
    final abs = value.abs();
    if (abs >= 100) return 2;
    if (abs >= 1) return 2;
    if (abs >= 0.01) return 4;
    if (abs == 0) return 2;
    return 8;
  }

  /// `₺248.360,42`
  ///
  /// With [trimWhole] a round number loses its `,00`, which keeps alert
  /// sentences short: `$120.000 üstüne çıkarsa`.
  static String price(
    num value, {
    Currency currency = Currency.tryLira,
    int? decimals,
    bool trimWhole = false,
  }) {
    final digits = trimWhole && value == value.roundToDouble()
        ? 0
        : decimals ?? decimalsFor(value);
    final sign = value < 0 ? _minus : '';
    return '$sign${currency.symbol}${_pattern(digits).format(value.abs())}';
  }

  /// `+₺3.412,00` / `−₺3.412,00`
  static String signedPrice(
    num value, {
    Currency currency = Currency.tryLira,
    int? decimals,
  }) {
    final digits = decimals ?? decimalsFor(value);
    final sign = value < 0 ? _minus : _plus;
    return '$sign${currency.symbol}${_pattern(digits).format(value.abs())}';
  }

  /// `1,39%`
  static String percent(num value, {int decimals = 2}) =>
      '${_pattern(decimals).format(value.abs())}%';

  /// `+1,39%` / `−1,39%`
  static String signedPercent(num value, {int decimals = 2}) {
    final sign = value < 0 ? _minus : _plus;
    return '$sign${_pattern(decimals).format(value.abs())}%';
  }

  /// `0,0850 BTC` — trailing zeros are kept for crypto so the column lines up,
  /// whole numbers are shown without decimals (`120 lot`).
  static String quantity(Decimal value, {String? unit, int? decimals}) {
    final asDouble = value.toDouble();
    final digits = decimals ?? (value.isInteger ? 0 : decimalsFor(asDouble));
    final text = _pattern(digits).format(asDouble);
    return unit == null ? text : '$text $unit';
  }

  /// Plain number without a currency symbol, e.g. inside a chart axis.
  static String number(num value, {int decimals = 2}) =>
      _pattern(decimals).format(value);

  /// `248,4 B` / `1,2 Mn` for tight spaces.
  static String compact(num value) {
    final abs = value.abs();
    final sign = value < 0 ? _minus : '';
    if (abs >= 1000000000) {
      return '$sign${_pattern(1).format(abs / 1000000000)} Mr';
    }
    if (abs >= 1000000) return '$sign${_pattern(1).format(abs / 1000000)} Mn';
    if (abs >= 1000) return '$sign${_pattern(1).format(abs / 1000)} B';
    return '$sign${_pattern(decimalsFor(abs)).format(abs)}';
  }
}
