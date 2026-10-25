import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_dimens.dart';
import 'app_typography.dart';

export 'app_colors.dart';
export 'app_dimens.dart';
export 'app_typography.dart';

/// The app ships with a single dark theme.
ThemeData buildAppTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  final colorScheme =
      ColorScheme.fromSeed(
        seedColor: AppColors.accent,
        brightness: Brightness.dark,
      ).copyWith(
        surface: AppColors.background,
        primary: AppColors.accent,
        onPrimary: AppColors.onAccent,
        secondary: AppColors.accent,
        error: AppColors.down,
        outline: AppColors.border,
      );

  return base.copyWith(
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.background,
    canvasColor: AppColors.background,
    splashFactory: InkRipple.splashFactory,
    // google_fonts exposes its own TextTheme type, so the family is applied
    // to Flutter's text theme by name instead.
    textTheme: base.textTheme.apply(
      fontFamily: GoogleFonts.manrope().fontFamily,
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.divider,
      thickness: 1,
      space: 1,
    ),
    iconTheme: const IconThemeData(color: AppColors.textPrimary, size: 20),
    cardTheme: const CardThemeData(color: AppColors.surface, elevation: 0),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.onAccent
            : AppColors.textSecondary,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.selected)
            ? AppColors.accent
            : AppColors.surfaceAlt,
      ),
      trackOutlineColor: const WidgetStatePropertyAll<Color>(
        Colors.transparent,
      ),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(AppRadius.smallCard),
      ),
      textStyle: AppText.captionSmall,
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: AppColors.accent,
      selectionColor: Color(0x33C6F36B),
      selectionHandleColor: AppColors.accent,
    ),
  );
}
