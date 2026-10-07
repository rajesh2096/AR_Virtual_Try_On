import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/utils/app_haptics.dart';

class AppImageCard extends StatelessWidget {
  final String imageUrl;
  final double aspectRatio;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;
  final bool isFavorite;
  final bool isSelected;
  final Widget? badge;
  final Widget? overlayContent;
  final BorderRadius? borderRadius;

  const AppImageCard({
    super.key,
    required this.imageUrl,
    this.aspectRatio = AppAspectRatio.fashionCard,
    this.onTap,
    this.onFavoriteTap,
    this.isFavorite = false,
    this.isSelected = false,
    this.badge,
    this.overlayContent,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? AppRadius.roundedLg;

    return AspectRatio(
      aspectRatio: aspectRatio,
      child: GestureDetector(
        onTap: () {
          if (onTap != null) {
            AppHaptics.lightImpact();
            onTap!();
          }
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: effectiveRadius,
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 2.0 : 1.0,
            ),
          ),
          child: ClipRRect(
            borderRadius: effectiveRadius,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Image
                CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppColors.surfaceElevated,
                    child: const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primaryLight,
                        ),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: AppColors.surfaceElevated,
                    child: const Center(
                      child: Icon(Icons.broken_image_rounded, color: AppColors.textMuted, size: 32),
                    ),
                  ),
                ),

                // Top Gradient Overlay (for icons visibility)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 60,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.5),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // Bottom Gradient Overlay (for text readability)
                if (overlayContent != null)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.85),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: overlayContent,
                    ),
                  ),

                // Badge top-left
                if (badge != null)
                  Positioned(
                    top: AppSpacing.sm,
                    left: AppSpacing.sm,
                    child: badge!,
                  ),

                // Favorite button top-right
                if (onFavoriteTap != null)
                  Positioned(
                    top: AppSpacing.sm,
                    right: AppSpacing.sm,
                    child: GestureDetector(
                      onTap: () {
                        AppHaptics.mediumImpact();
                        onFavoriteTap!();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          size: 18,
                          color: isFavorite ? AppColors.secondary : Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
