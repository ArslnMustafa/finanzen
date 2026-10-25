import 'package:decimal/decimal.dart';

/// Direction of a price alert.
enum AlertCondition {
  above('above', 'üstüne çıkarsa'),
  below('below', 'altına inerse');

  const AlertCondition(this.code, this.label);

  final String code;
  final String label;

  static AlertCondition fromCode(String code) =>
      AlertCondition.values.firstWhere((c) => c.code == code);
}

/// A price alert. Mirrors a row of `alerts`.
class AlertRule {
  const AlertRule({
    required this.id,
    required this.assetId,
    required this.condition,
    required this.targetPrice,
    required this.isActive,
    this.lastTriggeredAt,
  });

  final String id;
  final String assetId;
  final AlertCondition condition;
  final Decimal targetPrice;
  final bool isActive;
  final DateTime? lastTriggeredAt;

  AlertRule copyWith({bool? isActive}) => AlertRule(
    id: id,
    assetId: assetId,
    condition: condition,
    targetPrice: targetPrice,
    isActive: isActive ?? this.isActive,
    lastTriggeredAt: lastTriggeredAt,
  );
}
