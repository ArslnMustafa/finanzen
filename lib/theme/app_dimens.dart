/// Corner radii used across the app.
abstract final class AppRadius {
  static const largeCard = 22.0;
  static const smallCard = 16.0;
  static const button = 16.0;
  static const pill = 999.0;
}

/// Spacing scale. `screenPadding` is the horizontal gutter of every screen.
abstract final class AppSpacing {
  static const screenPadding = 20.0;
  static const section = 20.0;
  static const card = 10.0;
  static const tight = 6.0;
  static const small = 10.0;
  static const medium = 14.0;

  /// Minimum size of any tappable target.
  static const minTapTarget = 44.0;

  /// Maximum content width; on wide screens the app stays a centred column.
  static const maxContentWidth = 480.0;
}
