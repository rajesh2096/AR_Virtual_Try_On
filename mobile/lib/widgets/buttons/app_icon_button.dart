import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/app_haptics.dart';

class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final Color? color;
  final Color? backgroundColor;
  final String? tooltip;
  final bool isSelected;
  final Color? selectedColor;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 20.0,
    this.color,
    this.backgroundColor,
    this.tooltip,
    this.isSelected = false,
    this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = isSelected
        ? (selectedColor ?? AppColors.secondary)
        : (color ?? AppColors.textPrimary);

    final effectiveBg = backgroundColor ?? AppColors.surfaceElevated.withValues(alpha: 0.8);

    Widget btn = Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: AppRadius.roundedSm,
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (onPressed != null) {
              AppHaptics.selectionClick();
              onPressed!();
            }
          },
          borderRadius: AppRadius.roundedSm,
          child: Center(
            child: Icon(
              icon,
              size: size,
              color: effectiveColor,
            ),
          ),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: btn,
      );
    }

    return btn;
  }
}
