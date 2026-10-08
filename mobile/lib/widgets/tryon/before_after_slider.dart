import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/app_haptics.dart';

class BeforeAfterSlider extends StatefulWidget {
  final String beforeImageUrl;
  final String afterImageUrl;
  final String beforeLabel;
  final String afterLabel;

  const BeforeAfterSlider({
    super.key,
    required this.beforeImageUrl,
    required this.afterImageUrl,
    this.beforeLabel = 'ORIGINAL',
    this.afterLabel = 'AI TRY-ON',
  });

  @override
  State<BeforeAfterSlider> createState() => _BeforeAfterSliderState();
}

class _BeforeAfterSliderState extends State<BeforeAfterSlider> {
  double _splitRatio = 0.5; // 0.0 (all after) to 1.0 (all before)

  void _updateSplitRatio(double localX, double totalWidth) {
    setState(() {
      _splitRatio = (localX / totalWidth).clamp(0.02, 0.98);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: AppAspectRatio.tryOnResult,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: AppRadius.roundedLg,
          border: Border.all(color: AppColors.border, width: 1.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final height = constraints.maxHeight;
            final splitPos = width * _splitRatio;

            return Stack(
              fit: StackFit.expand,
              children: [
                // 1. Bottom Layer: AFTER (Try-On Result)
                CachedNetworkImage(
                  imageUrl: widget.afterImageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: AppColors.surfaceElevated,
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryLight),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: AppColors.surfaceElevated,
                    child: const Center(
                      child: Icon(Icons.broken_image_rounded, color: AppColors.textMuted, size: 36),
                    ),
                  ),
                ),

                // 2. Top Layer (Clipped): BEFORE (Original Model)
                ClipRect(
                  clipper: _LeftSplitClipper(splitPos),
                  child: CachedNetworkImage(
                    imageUrl: widget.beforeImageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: AppColors.surfaceElevated,
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryLight),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.surfaceElevated,
                      child: const Center(
                        child: Icon(Icons.person_rounded, color: AppColors.textMuted, size: 36),
                      ),
                    ),
                  ),
                ),

                // 3. Before Label (Top-Left)
                Positioned(
                  top: AppSpacing.sm,
                  left: AppSpacing.sm,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: AppRadius.roundedPill,
                    ),
                    child: Text(
                      widget.beforeLabel,
                      style: AppTypography.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),

                // 4. After Label (Top-Right)
                Positioned(
                  top: AppSpacing.sm,
                  right: AppSpacing.sm,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark.withValues(alpha: 0.85),
                      borderRadius: AppRadius.roundedPill,
                    ),
                    child: Text(
                      widget.afterLabel,
                      style: AppTypography.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),

                // 5. Divider Line
                Positioned(
                  left: splitPos - 1.0,
                  top: 0,
                  bottom: 0,
                  width: 2.0,
                  child: Container(
                    color: Colors.white,
                  ),
                ),

                // 6. Handle Icon Circle
                Positioned(
                  left: splitPos - 18.0,
                  top: (height / 2) - 18.0,
                  child: Container(
                    width: 36.0,
                    height: 36.0,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevated,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.compare_arrows_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                // 7. Gesture Detector Overlay across the full area
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onHorizontalDragStart: (details) {
                    AppHaptics.selectionClick();
                    _updateSplitRatio(details.localPosition.dx, width);
                  },
                  onHorizontalDragUpdate: (details) {
                    _updateSplitRatio(details.localPosition.dx, width);
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _LeftSplitClipper extends CustomClipper<Rect> {
  final double splitX;

  _LeftSplitClipper(this.splitX);

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(0, 0, splitX, size.height);
  }

  @override
  bool shouldReclip(covariant _LeftSplitClipper oldClipper) {
    return oldClipper.splitX != splitX;
  }
}
