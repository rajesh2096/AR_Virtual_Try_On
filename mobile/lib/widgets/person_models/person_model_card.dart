import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_typography.dart';
import '../../models/person_profile_model.dart';
import '../../widgets/cards/app_image_card.dart';
import '../../widgets/feedback/app_feedback_widgets.dart';

class PersonModelCard extends StatelessWidget {
  final PersonProfileModel model;
  final VoidCallback? onTap;
  final VoidCallback? onSetDefault;
  final VoidCallback? onDelete;
  final bool isSelected;
  final bool selectMode;

  const PersonModelCard({
    super.key,
    required this.model,
    this.onTap,
    this.onSetDefault,
    this.onDelete,
    this.isSelected = false,
    this.selectMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = model.imageUrl ?? '';

    return AppImageCard(
      imageUrl: imageUrl,
      aspectRatio: AppAspectRatio.personModel,
      onTap: onTap,
      isSelected: isSelected || model.isDefault,
      badge: model.isDefault
          ? const AppBadge.luxury(
              text: 'DEFAULT MODEL',
              icon: Icons.verified_rounded,
            )
          : null,
      overlayContent: _buildCardFooter(context),
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
                model.title,
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
        const SizedBox(height: 4),
        if (!model.isDefault && onSetDefault != null && !selectMode) ...[
          GestureDetector(
            onTap: onSetDefault,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.25),
                borderRadius: AppRadius.roundedPill,
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.5), width: 0.8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle_outline_rounded, size: 12, color: AppColors.primaryLight),
                  const SizedBox(width: 4),
                  Text(
                    'Set as Default',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.primaryLight,
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ] else if (model.isDefault) ...[
          Text(
            'Active for AI Try-On',
            style: AppTypography.caption.copyWith(
              color: AppColors.accent,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
