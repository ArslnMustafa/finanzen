import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../format/money.dart';

/// Percentage change, always with a sign so colour is not the only cue.
class ChangeText extends StatelessWidget {
  const ChangeText(this.percent, {super.key, this.style});

  final double percent;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Text(
      Fmt.signedPercent(percent),
      style: (style ?? AppText.numberBody).copyWith(
        color: AppColors.forChange(percent),
      ),
      semanticsLabel: percent >= 0
          ? 'yüzde ${Fmt.percent(percent)} artış'
          : 'yüzde ${Fmt.percent(percent)} düşüş',
    );
  }
}

/// Dark pill used on the accent card: `+₺3.412,00 · +1,39%`.
class ChangePill extends StatelessWidget {
  const ChangePill({
    super.key,
    required this.amount,
    required this.percent,
    required this.currency,
  });

  final num amount;
  final double percent;
  final Currency currency;

  @override
  Widget build(BuildContext context) {
    final color = percent >= 0 ? AppColors.up : AppColors.down;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.onAccent,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        '${Fmt.signedPrice(amount, currency: currency, decimals: 0)} · '
        '${Fmt.signedPercent(percent)}',
        style: AppText.numberSmall.copyWith(color: color),
      ),
    );
  }
}
