import 'package:decimal/decimal.dart';

import '../../core/format/money.dart';

/// A position the user owns. Mirrors a row of `holdings`.
class Holding {
  const Holding({
    required this.id,
    required this.assetId,
    required this.quantity,
    required this.avgCost,
    required this.currency,
  });

  final String id;
  final String assetId;

  /// How much the user holds: `0.0850` BTC, `120` lot.
  final Decimal quantity;

  /// Average buy price per unit, in [currency].
  final Decimal avgCost;

  /// Currency the position was bought in.
  final Currency currency;
}
