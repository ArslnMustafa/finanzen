import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// Rounded square that carries either a short ticker or an icon.
class IconBox extends StatelessWidget {
  const IconBox({super.key, this.label, this.icon, this.size = 42})
    : assert(label != null || icon != null, 'label veya icon gerekli');

  final String? label;
  final IconData? icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(size / 3),
      ),
      child: icon != null
          ? Icon(icon, size: size * 0.45, color: AppColors.iconBoxText)
          : Text(
              label!,
              style: AppText.iconBox,
              maxLines: 1,
              overflow: TextOverflow.clip,
            ),
    );
  }
}
