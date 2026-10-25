import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Keeps content in a centred column no wider than 480 px, so the phone
/// layout stays intact on a desktop browser.
class CenteredColumn extends StatelessWidget {
  const CenteredColumn({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSpacing.maxContentWidth),
        child: child,
      ),
    );
  }
}

/// Screen background plus the centred column and the standard side gutter.
class AppScreen extends StatelessWidget {
  const AppScreen({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.screenPadding,
    ),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: CenteredColumn(
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
