import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/app_buttons.dart';
import '../../../core/widgets/asset_picker.dart';
import '../../../core/widgets/form_fields.dart';
import '../../../data/models/asset.dart';
import '../../../data/models/holding.dart';
import '../../../data/providers/app_providers.dart';
import '../../../theme/app_theme.dart';
import 'sheet_shell.dart';

/// Opens the "add to portfolio" form.
Future<void> showHoldingFormSheet(
  BuildContext context, {
  String? assetId,
  Decimal? suggestedPrice,
}) => showAppSheet(
  context,
  child: _HoldingForm(assetId: assetId, suggestedPrice: suggestedPrice),
);

class _HoldingForm extends ConsumerStatefulWidget {
  const _HoldingForm({this.assetId, this.suggestedPrice});

  final String? assetId;
  final Decimal? suggestedPrice;

  @override
  ConsumerState<_HoldingForm> createState() => _HoldingFormState();
}

class _HoldingFormState extends ConsumerState<_HoldingForm> {
  Asset? _asset;
  final _quantity = TextEditingController();
  final _cost = TextEditingController();
  String? _error;

  @override
  void initState() {
    super.initState();
    final price = widget.suggestedPrice;
    if (price != null && price > Decimal.zero) {
      _cost.text = price.toString().replaceAll('.', ',');
    }
  }

  @override
  void dispose() {
    _quantity.dispose();
    _cost.dispose();
    super.dispose();
  }

  void _submit() {
    final asset = _asset;
    final quantity = parseDecimal(_quantity.text);
    final cost = parseDecimal(_cost.text);

    if (asset == null) {
      setState(() => _error = 'Önce bir varlık seç.');
      return;
    }
    if (quantity == null || quantity <= Decimal.zero) {
      setState(() => _error = 'Geçerli bir miktar gir.');
      return;
    }
    if (cost == null || cost <= Decimal.zero) {
      setState(() => _error = 'Geçerli bir alış fiyatı gir.');
      return;
    }

    ref
        .read(holdingsProvider.notifier)
        .add(
          Holding(
            id: 'h${DateTime.now().microsecondsSinceEpoch}',
            assetId: asset.id,
            quantity: quantity,
            avgCost: cost,
            currency: asset.currency,
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
        Text('Portföye ekle', style: AppText.sectionTitle),
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
          label: 'Miktar',
          child: DecimalField(
            controller: _quantity,
            hintText: '0,00',
            suffix: _asset?.unit,
          ),
        ),
        const SizedBox(height: 14),
        LabeledField(
          label: 'Alış fiyatı (birim başına)',
          child: DecimalField(
            controller: _cost,
            hintText: '0,00',
            suffix: _asset?.currency.symbol,
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(_error!, style: AppText.caption.copyWith(color: AppColors.down)),
        ],
        const SizedBox(height: 20),
        AccentButton(label: 'Portföye ekle', onPressed: _submit),
      ],
    );
  }
}
