import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/app_haptics.dart';

enum AppButtonVariant { primary, secondary, outlined, text, luxury }
enum AppButtonSize { small, medium, large }

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool isLoading;
  final IconData? icon;
  final Widget? customIcon;
  final bool isFullWidth;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.icon,
    this.customIcon,
    this.isFullWidth = true,
  });

  const AppButton.primary({
    super.key,
    required this.text,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.icon,
    this.customIcon,
    this.isFullWidth = true,
  }) : variant = AppButtonVariant.primary;

  const AppButton.secondary({
    super.key,
    required this.text,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.icon,
    this.customIcon,
    this.isFullWidth = true,
  }) : variant = AppButtonVariant.secondary;

  const AppButton.outlined({
    super.key,
    required this.text,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.icon,
    this.customIcon,
    this.isFullWidth = true,
  }) : variant = AppButtonVariant.outlined;

  const AppButton.text({
    super.key,
    required this.text,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.icon,
    this.customIcon,
    this.isFullWidth = false,
  }) : variant = AppButtonVariant.text;

  const AppButton.luxury({
    super.key,
    required this.text,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.icon,
    this.customIcon,
    this.isFullWidth = true,
  }) : variant = AppButtonVariant.luxury;

  @override
  Widget build(BuildContext context) {
    final effectiveHeight = _getHeight();
    final effectivePadding = _getPadding();
    final textStyle = _getTextStyle();

    Widget content = _buildContent(textStyle);

    Widget button;
    switch (variant) {
      case AppButtonVariant.primary:
        button = ElevatedButton(
          onPressed: isLoading ? null : _handleTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
            elevation: 0,
            shadowColor: Colors.transparent,
            padding: effectivePadding,
            shape: const RoundedRectangleBorder(borderRadius: AppRadius.roundedMd),
          ),
          child: content,
        );
        break;

      case AppButtonVariant.secondary:
        button = ElevatedButton(
          onPressed: isLoading ? null : _handleTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.surfaceElevated,
            foregroundColor: AppColors.textPrimary,
            elevation: 0,
            side: const BorderSide(color: AppColors.border, width: 1),
            padding: effectivePadding,
            shape: const RoundedRectangleBorder(borderRadius: AppRadius.roundedMd),
          ),
          child: content,
        );
        break;

      case AppButtonVariant.outlined:
        button = OutlinedButton(
          onPressed: isLoading ? null : _handleTap,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryLight,
            side: const BorderSide(color: AppColors.primary, width: 1.5),
            padding: effectivePadding,
            shape: const RoundedRectangleBorder(borderRadius: AppRadius.roundedMd),
          ),
          child: content,
        );
        break;

      case AppButtonVariant.luxury:
        button = ElevatedButton(
          onPressed: isLoading ? null : _handleTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: const Color(0xFF141622),
            elevation: 0,
            padding: effectivePadding,
            shape: const RoundedRectangleBorder(borderRadius: AppRadius.roundedMd),
          ),
          child: content,
        );
        break;

      case AppButtonVariant.text:
        button = TextButton(
          onPressed: isLoading ? null : _handleTap,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primaryLight,
            padding: effectivePadding,
            shape: const RoundedRectangleBorder(borderRadius: AppRadius.roundedSm),
          ),
          child: content,
        );
        break;
    }

    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        height: effectiveHeight,
        child: button,
      );
    }

    return SizedBox(
      height: effectiveHeight,
      child: button,
    );
  }

  void _handleTap() {
    if (onPressed != null) {
      AppHaptics.selectionClick();
      onPressed!();
    }
  }

  double _getHeight() {
    switch (size) {
      case AppButtonSize.small:
        return 38.0;
      case AppButtonSize.medium:
        return 48.0;
      case AppButtonSize.large:
        return 56.0;
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case AppButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0);
      case AppButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0);
      case AppButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 28.0, vertical: 16.0);
    }
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case AppButtonSize.small:
        return AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600);
      case AppButtonSize.medium:
        return AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w600);
      case AppButtonSize.large:
        return AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w700);
    }
  }

  Widget _buildContent(TextStyle style) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.2,
          valueColor: AlwaysStoppedAnimation<Color>(
            variant == AppButtonVariant.luxury ? const Color(0xFF141622) : Colors.white,
          ),
        ),
      );
    }

    final effectiveIcon = customIcon ?? (icon != null ? Icon(icon, size: size == AppButtonSize.small ? 16 : 20) : null);

    if (effectiveIcon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          effectiveIcon,
          const SizedBox(width: AppSpacing.xs),
          Text(text, style: style),
        ],
      );
    }

    return Text(text, style: style);
  }
}
