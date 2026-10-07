import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../core/constants/app_constants.dart';

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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
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
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.camera_alt_rounded, color: AppColors.primaryLight),
              ),
              title: const Text('Take a Photo (Camera)', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
              subtitle: const Text('Capture using device camera', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              onTap: () => _pick(context, ImageSource.camera),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.photo_library_rounded, color: AppColors.secondary),
              ),
              title: const Text('Choose from Gallery', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
              subtitle: const Text('Select existing photo from storage', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              onTap: () => _pick(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }
}
