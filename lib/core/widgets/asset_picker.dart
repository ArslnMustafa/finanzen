import 'package:flutter/material.dart';

import '../../data/models/asset.dart';
import '../../theme/app_theme.dart';
import 'app_search_field.dart';
import 'icon_box.dart';

/// Search-and-pick list of assets, used by both forms.
class AssetPicker extends StatefulWidget {
  const AssetPicker({
    super.key,
    required this.assets,
    required this.selected,
    required this.onSelect,
    this.onClear,
  });

  final List<Asset> assets;
  final Asset? selected;
  final ValueChanged<Asset> onSelect;

  /// Called by the "Değiştir" button so the parent can drop the selection.
  final VoidCallback? onClear;

  @override
  State<AssetPicker> createState() => _AssetPickerState();
}

class _AssetPickerState extends State<AssetPicker> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final selected = widget.selected;
    if (selected != null) {
      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppRadius.button),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            IconBox(label: selected.shortCode, size: 36),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(selected.name, style: AppText.listTitle),
                  const SizedBox(height: 2),
                  Text(selected.subtitle, style: AppText.captionSmall),
                ],
              ),
            ),
            TextButton(
              onPressed: widget.onClear,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.accent,
                minimumSize: const Size(AppSpacing.minTapTarget, 36),
              ),
              child: const Text('Değiştir'),
            ),
          ],
        ),
      );
    }

    final needle = _query.toLowerCase();
    final matches = widget.assets
        .where(
          (asset) =>
              needle.isEmpty ||
              asset.symbol.toLowerCase().contains(needle) ||
              asset.name.toLowerCase().contains(needle),
        )
        .take(6)
        .toList();

    return Column(
      children: [
        AppSearchField(
          hintText: 'Hisse, coin, fon ara…',
          onChanged: (value) => setState(() => _query = value),
        ),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 230),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: matches.length,
            separatorBuilder: (_, _) => const Divider(),
            itemBuilder: (context, index) {
              final asset = matches[index];
              return InkWell(
                onTap: () => widget.onSelect(asset),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  child: Row(
                    children: [
                      IconBox(label: asset.shortCode, size: 34),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(asset.name, style: AppText.listTitle),
                            const SizedBox(height: 2),
                            Text(asset.subtitle, style: AppText.captionSmall),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
