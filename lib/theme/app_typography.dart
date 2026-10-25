import 'package:flutter/painting.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

const _tabular = <FontFeature>[FontFeature.tabularFigures()];

/// Text styles for the app.
///
/// Prose uses Manrope; every price, quantity and percentage uses JetBrains
/// Mono with tabular figures so numbers stay aligned between rows.
abstract final class AppText {
  static TextStyle _sans({
    required double size,
    required FontWeight weight,
    Color color = AppColors.textPrimary,
    double? height,
    double? letterSpacing,
  }) => GoogleFonts.manrope(
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
    letterSpacing: letterSpacing,
  );

  static TextStyle _mono({
    required double size,
    required FontWeight weight,
    Color color = AppColors.textPrimary,
    double? letterSpacing,
  }) => GoogleFonts.jetBrainsMono(
    fontSize: size,
    fontWeight: weight,
    color: color,
    letterSpacing: letterSpacing,
    fontFeatures: _tabular,
  );

  // Prose ---------------------------------------------------------------

  /// Screen title, e.g. "Piyasalar".
  static TextStyle get screenTitle =>
      _sans(size: 26, weight: FontWeight.w800, letterSpacing: -0.4);

  /// Section heading inside a screen, e.g. "İzleme listem".
  static TextStyle get sectionTitle => _sans(size: 17, weight: FontWeight.w700);

  /// Primary line of a list row.
  static TextStyle get listTitle => _sans(size: 15, weight: FontWeight.w700);

  static TextStyle get body =>
      _sans(size: 15, weight: FontWeight.w500, color: AppColors.textPrimary);

  static TextStyle get bodySecondary =>
      _sans(size: 14, weight: FontWeight.w500, color: AppColors.textSecondary);

  static TextStyle get caption =>
      _sans(size: 13, weight: FontWeight.w500, color: AppColors.textSecondary);

  static TextStyle get captionSmall =>
      _sans(size: 12, weight: FontWeight.w600, color: AppColors.textSecondary);

  static TextStyle get button => _sans(size: 15, weight: FontWeight.w700);

  // Numbers -------------------------------------------------------------

  /// Hero price on the home and asset detail screens.
  static TextStyle get priceHero =>
      _mono(size: 35, weight: FontWeight.w600, letterSpacing: -1);

  /// Price on a list row.
  static TextStyle get priceRow => _mono(size: 15, weight: FontWeight.w600);

  static TextStyle get numberBody => _mono(size: 14, weight: FontWeight.w500);

  static TextStyle get numberSmall => _mono(size: 12, weight: FontWeight.w600);

  /// Number inside the accent pill on a dark background.
  static TextStyle get numberStat => _mono(size: 17, weight: FontWeight.w600);

  /// Short symbol shown inside a square icon box.
  static TextStyle get iconBox =>
      _mono(size: 13, weight: FontWeight.w600, color: AppColors.iconBoxText);
}
