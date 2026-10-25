import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/asset_picker.dart';
import '../../../core/widgets/form_fields.dart';
import '../../../data/models/alert_rule.dart';
import '../../../data/models/asset.dart';
import '../../../data/providers/app_providers.dart';
import '../../../theme/app_theme.dart';
import '../../portfolio/widgets/sheet_shell.dart';

/// Opens the "create alert" form.
Future<void> showAlertFormSheet(BuildContext context, {String? assetId}) =>
    showAppSheet(context, child: _AlertForm(assetId: assetId));

class _AlertForm extends ConsumerStatefulWidget {
  const _AlertForm({this.assetId});

  final String? assetId;

  @override
  ConsumerState<_AlertForm> createState() => _AlertFormState();
}

class _AlertFormState extends ConsumerState<_AlertForm> {
  Asset? _asset;
  AlertCondition _condition = AlertCondition.above;
  final _target = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _target.dispose();
    super.dispose();
  }

  void _submit() {
    final asset = _asset;
    final target = parseDecimal(_target.text);

    if (asset == null) {
      setState(() => _error = 'Önce bir varlık seç.');
      return;
    }
    if (target == null || target <= Decimal.zero) {
      setState(() => _error = 'Geçerli bir hedef fiyat gir.');
      return;
    }

    ref
        .read(alertsProvider.notifier)
        .add(
          AlertRule(
            id: 'a${DateTime.now().microsecondsSinceEpoch}',
            assetId: asset.id,
            condition: _condition,
            targetPrice: target,
            isActive: true,
          ),
        );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final assets = ref.watch(assetsProvider).value ?? const <Asset>[];
    final preselected = widget.assetId;
    if (_asset == null && preselected != null) {
      _asset = ref.watch(assetsByIdProvider)[preselected];
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Alarm kur', style: AppText.sectionTitle),
        const SizedBox(height: 16),
        LabeledField(
          label: 'Varlık',
          child: AssetPicker(
            assets: assets,
            selected: _asset,
            onSelect: (asset) => setState(() => _asset = asset),
            onClear: () => setState(() => _asset = null),
          ),
        ),
        const SizedBox(height: 14),
        LabeledField(
          label: 'Koşul',
          child: Row(
            children: [
              for (final condition in AlertCondition.values) ...[
                if (condition != AlertCondition.values.first)
                  const SizedBox(width: AppSpacing.card),
                Expanded(
                  child: _ConditionOption(
                    label: condition == AlertCondition.above
                        ? 'Üstüne çıkarsa'
                        : 'Altına inerse',
                    selected: _condition == condition,
                    onTap: () => setState(() => _condition = condition),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        LabeledField(
          label: 'Hedef fiyat',
          child: DecimalField(
            controller: _target,
            hintText: '0,00',
            suffix: _asset?.currency.symbol,
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(_error!, style: AppText.caption.copyWith(color: AppColors.down)),
        ],
        const SizedBox(height: 20),
        AccentButton(label: 'Alarmı kur', onPressed: _submit),
      ],
    );
  }
}

class _ConditionOption extends StatelessWidget {
  const _ConditionOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.button),
        child: Container(
          height: AppSpacing.minTapTarget,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? AppColors.segmentSelected : AppColors.background,
            borderRadius: BorderRadius.circular(AppRadius.button),
            border: Border.all(
              color: selected ? AppColors.segmentSelected : AppColors.border,
            ),
          ),
          child: Text(
            label,
            style: AppText.captionSmall.copyWith(
              fontSize: 13,
              color: selected ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
