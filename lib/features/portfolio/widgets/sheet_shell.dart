import 'package:flutter/material.dart';

import '../../../theme/app_theme.dart';

/// Bottom sheet styled like the rest of the app: dark surface, rounded top,
/// grab handle, keyboard-aware padding and the same 480 px content cap.
Future<void> showAppSheet(BuildContext context, {required Widget child}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    isScrollControlled: true,
    showDragHandle: false,
    constraints: const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppRadius.largeCard),
      ),
    ),
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.screenPadding,
        right: AppSpacing.screenPadding,
        top: 10,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 38,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
            child,
          ],
        ),
      ),
    ),
  );
}
