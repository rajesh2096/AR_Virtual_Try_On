import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_typography.dart';
import '../../models/garment_model.dart';
import '../../widgets/cards/app_image_card.dart';

class GarmentCard extends StatelessWidget {
  final GarmentModel garment;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onDelete;
  final bool isSelected;
  final bool selectMode;

  const GarmentCard({
    super.key,
    required this.garment,
    this.onTap,
    this.onFavoriteToggle,
    this.onDelete,
    this.isSelected = false,
    this.selectMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = garment.imageUrl ?? '';

    return AppImageCard(
      imageUrl: imageUrl,
      aspectRatio: AppAspectRatio.fashionCard,
      onTap: onTap,
      onFavoriteTap: selectMode ? null : onFavoriteToggle,
      isFavorite: garment.isFavorite,
      isSelected: isSelected,
      badge: _buildCategoryBadge(),
      overlayContent: _buildCardFooter(context),
    );
  }

  Widget _buildCategoryBadge() {
    final displayCategory = garment.subcategory?.name ?? garment.category;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated.withValues(alpha: 0.85),
        borderRadius: AppRadius.roundedPill,
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: Text(
        displayCategory.toUpperCase(),
        style: AppTypography.caption.copyWith(
          color: AppColors.textPrimary,
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Widget _buildCardFooter(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                garment.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5,
                ),
              ),
            ),
            if (onDelete != null && !selectMode) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onDelete,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    size: 15,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ],
        ),
        if (garment.brand != null && garment.brand!.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            garment.brand!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.caption.copyWith(
              color: AppColors.accent,
              fontWeight: FontWeight.w500,
            ),
          ),
        ] else if (garment.size != null || garment.primaryColor != null) ...[
          const SizedBox(height: 2),
          Text(
            [
              if (garment.size != null) 'Size: ${garment.size}',
              if (garment.primaryColor != null) garment.primaryColor,
            ].join(' • '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}
