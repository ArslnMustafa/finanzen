import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Filled accent button, used for the primary action on a screen.
class AccentButton extends StatelessWidget {
  const AccentButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.expand = true,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final button = FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.onAccent,
        disabledBackgroundColor: AppColors.surfaceAlt,
        disabledForegroundColor: AppColors.textSecondary,
        minimumSize: const Size(0, AppSpacing.minTapTarget + 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
        textStyle: AppText.button,
      ),
      child: _content(AppColors.onAccent),
    );
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }

  Widget _content(Color color) {
    if (icon == null) return Text(label);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }
}

/// Outlined button, used for the secondary action next to [AccentButton].
class GhostButton extends StatelessWidget {
  const GhostButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.expand = true,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final button = OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        side: const BorderSide(color: AppColors.border),
        minimumSize: const Size(0, AppSpacing.minTapTarget + 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
        textStyle: AppText.button,
      ),
      child: icon == null
          ? Text(label)
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18),
                const SizedBox(width: 8),
                Text(label),
              ],
            ),
    );
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// Small accent pill, e.g. the "Ekle" button in the portfolio header.
class PillButton extends StatelessWidget {
  const PillButton({super.key, required this.label, this.icon, this.onPressed});

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.onAccent,
        minimumSize: const Size(AppSpacing.minTapTarget, 38),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        textStyle: AppText.captionSmall.copyWith(fontSize: 13),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: AppColors.onAccent),
            const SizedBox(width: 6),
          ],
          Text(label),
        ],
      ),
    );
  }
}

/// Round 44 px icon button used in app bars.
class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.color = AppColors.textPrimary,
    this.background = AppColors.surface,
  });

  final IconData icon;

  /// Also used as the accessibility label; icon-only buttons need one.
  final String tooltip;
  final VoidCallback? onPressed;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        child: Material(
          color: background,
          shape: CircleBorder(side: const BorderSide(color: AppColors.border)),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            child: SizedBox(
              width: AppSpacing.minTapTarget,
              height: AppSpacing.minTapTarget,
              child: Icon(icon, size: 20, color: color),
            ),
          ),
        ),
      ),
    );
  }
}
