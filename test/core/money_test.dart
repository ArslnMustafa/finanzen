import 'package:decimal/decimal.dart';
import 'package:finans_takip/core/format/money.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Fmt.price', () {
    test('lira amounts use Turkish separators and a leading symbol', () {
      expect(Fmt.price(248360.42), '₺248.360,42');
    });

    test('dollar amounts keep the Turkish separators', () {
      expect(Fmt.price(112480.5, currency: Currency.usd), r'$112.480,50');
    });

    test('small prices get more decimals', () {
      expect(Fmt.price(0.00002341, currency: Currency.usd), r'$0,00002341');
    });

    test('negative prices use a real minus sign', () {
      expect(Fmt.price(-12.5), '−₺12,50');
    });
  });

  group('Fmt.signedPrice', () {
    test('always shows the sign', () {
      expect(Fmt.signedPrice(3412, decimals: 0), '+₺3.412');
      expect(Fmt.signedPrice(-3412, decimals: 0), '−₺3.412');
    });
  });

  group('Fmt.signedPercent', () {
    test('formats the example from the design', () {
      expect(Fmt.signedPercent(1.39), '+1,39%');
      expect(Fmt.signedPercent(-0.72), '−0,72%');
      expect(Fmt.signedPercent(0), '+0,00%');
    });
  });

  group('Fmt.quantity', () {
    test('keeps crypto decimals and appends the unit', () {
      expect(
        Fmt.quantity(Decimal.parse('0.0850'), unit: 'BTC', decimals: 4),
        '0,0850 BTC',
      );
    });

    test('whole numbers have no decimals', () {
      expect(Fmt.quantity(Decimal.parse('120'), unit: 'lot'), '120 lot');
    });
  });

  test('Fmt.compact shortens large numbers', () {
    expect(Fmt.compact(248360), '248,4 B');
    expect(Fmt.compact(1250000), '1,3 Mn');
  });
}
