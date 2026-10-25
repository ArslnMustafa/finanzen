import 'package:flutter/widgets.dart';

/// Single source of truth for every colour in the app.
///
/// The palette comes from the product design; no screen should define its own
/// colour literals.
abstract final class AppColors {
  /// Screen background.
  static const background = Color(0xFF0E1116);

  /// Card and sheet surfaces.
  static const surface = Color(0xFF171B22);

  /// Bottom navigation background.
  static const navBackground = Color(0xFF12161C);

  /// Card and input borders.
  static const border = Color(0xFF262C36);

  /// Hairline separator inside lists.
  static const divider = Color(0xFF1E232B);

  /// Secondary surface, used for icon boxes and unselected chips.
  static const surfaceAlt = Color(0xFF222833);

  /// Selected segment inside a segmented control.
  static const segmentSelected = Color(0xFF2A313C);

  static const textPrimary = Color(0xFFE8EAED);
  static const textSecondary = Color(0xFF9AA3AE);

  /// Symbol text inside an icon box.
  static const iconBoxText = Color(0xFFC9D1DB);

  /// Brand accent (lime) and the text colour that sits on top of it.
  static const accent = Color(0xFFC6F36B);
  static const onAccent = Color(0xFF0E1116);

  /// Price movement. Always pair these with a `+` / `−` sign so the
  /// information does not depend on colour alone.
  static const up = Color(0xFF3DDC97);
  static const down = Color(0xFFFF7A6B);

  /// Extra series colours for the allocation donut.
  static const chartBlue = Color(0xFF7FB8FF);
  static const chartOrange = Color(0xFFFFB86B);
  static const chartGrey = Color(0xFF5B6474);

  /// Colour for a signed value: up when positive, down when negative and
  /// secondary text when flat.
  static Color forChange(num value) {
    if (value > 0) return up;
    if (value < 0) return down;
    return textSecondary;
  }
}
