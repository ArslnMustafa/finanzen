import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Standard surface: dark panel, hairline border, generous corner radius.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = AppRadius.smallCard,
    this.color = AppColors.surface,
    this.onTap,
    this.border = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color color;
  final VoidCallback? onTap;
  final bool border;

  @override
  Widget build(BuildContext context) {
    final decorated = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: border ? Border.all(color: AppColors.border) : null,
      ),
      child: child,
    );

    if (onTap == null) return decorated;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(radius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(onTap: onTap, child: decorated),
    );
  }
}
