import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Section title with an optional action on the right ("Tümü").
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppText.sectionTitle),
        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              minimumSize: const Size(44, 36),
              padding: const EdgeInsets.symmetric(horizontal: 8),
              foregroundColor: AppColors.accent,
            ),
            child: Text(
              actionLabel!,
              style: AppText.captionSmall.copyWith(color: AppColors.accent),
            ),
          ),
      ],
    );
  }
}
