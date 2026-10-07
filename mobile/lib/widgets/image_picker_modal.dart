import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_tokens.dart';
import '../core/theme/app_typography.dart';
import '../core/utils/app_haptics.dart';

class ImagePickerModal extends StatelessWidget {
  final Function(File) onImageSelected;
  final String title;

  const ImagePickerModal({
    super.key,
    required this.onImageSelected,
    this.title = 'Select Image Source',
  });

  static Future<void> show({
    required BuildContext context,
    required Function(File) onImageSelected,
    String title = 'Select Image Source',
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheetRadius),
      builder: (ctx) => ImagePickerModal(
        onImageSelected: onImageSelected,
        title: title,
      ),
    );
  }

  Future<void> _pick(BuildContext context, ImageSource source) async {
    Navigator.of(context).pop();
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 90,
      );
      if (picked != null) {
        AppHaptics.mediumImpact();
        onImageSelected(File(picked.path));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: const BoxDecoration(
                  color: AppColors.border,
                  borderRadius: AppRadius.roundedPill,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: AppTypography.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            ListTile(
              shape: const RoundedRectangleBorder(borderRadius: AppRadius.roundedMd),
              tileColor: AppColors.surfaceElevated,
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: AppRadius.roundedSm,
                ),
                child: const Icon(Icons.camera_alt_rounded, color: AppColors.primaryLight),
              ),
              title: const Text('Take a Photo (Camera)', style: AppTypography.titleMedium),
              subtitle: const Text('Capture using device camera', style: AppTypography.caption),
              onTap: () => _pick(context, ImageSource.camera),
            ),
            const SizedBox(height: AppSpacing.sm),
            ListTile(
              shape: const RoundedRectangleBorder(borderRadius: AppRadius.roundedMd),
              tileColor: AppColors.surfaceElevated,
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.15),
                  borderRadius: AppRadius.roundedSm,
                ),
                child: const Icon(Icons.photo_library_rounded, color: AppColors.secondary),
              ),
              title: const Text('Choose from Gallery', style: AppTypography.titleMedium),
              subtitle: const Text('Select existing photo from storage', style: AppTypography.caption),
              onTap: () => _pick(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }
}
