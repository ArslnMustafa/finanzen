import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'app_buttons.dart';

/// Shown where a list has nothing in it yet.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 12),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: AppColors.iconBoxText),
          ),
          const SizedBox(height: 14),
          Text(title, style: AppText.listTitle),
          const SizedBox(height: 6),
          Text(message, style: AppText.caption, textAlign: TextAlign.center),
          if (actionLabel != null) ...[
            const SizedBox(height: 16),
            AccentButton(
              label: actionLabel!,
              onPressed: onAction,
              expand: false,
            ),
          ],
        ],
      ),
    );
  }
}

/// Error state with a retry button and, when known, the time of the last
/// successful update.
class ErrorNotice extends StatelessWidget {
  const ErrorNotice({
    super.key,
    required this.message,
    this.lastUpdated,
    this.onRetry,
  });

  final String message;
  final String? lastUpdated;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 12),
      child: Column(
        children: [
          Text(
            message,
            style: AppText.body.copyWith(color: AppColors.down),
            textAlign: TextAlign.center,
          ),
          if (lastUpdated != null) ...[
            const SizedBox(height: 6),
            Text('Son güncelleme: $lastUpdated', style: AppText.caption),
          ],
          if (onRetry != null) ...[
            const SizedBox(height: 14),
            GhostButton(
              label: 'Yeniden dene',
              onPressed: onRetry,
              expand: false,
            ),
          ],
        ],
      ),
    );
  }
}
