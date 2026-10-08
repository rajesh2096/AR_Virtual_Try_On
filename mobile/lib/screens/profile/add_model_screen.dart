import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_typography.dart';
import '../../models/person_profile_model.dart';
import '../../services/person_profile_service.dart';
import '../../widgets/buttons/app_button.dart';
import '../../widgets/inputs/app_text_field.dart';
import '../../widgets/image_picker_modal.dart';

class AddModelScreen extends StatefulWidget {
  final bool makeDefault;

  const AddModelScreen({super.key, this.makeDefault = false});

  @override
  State<AddModelScreen> createState() => _AddModelScreenState();
}

class _AddModelScreenState extends State<AddModelScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController(text: 'Standing Pose');
  File? _selectedImage;
  bool _isUploading = false;
  late bool _isDefault;

  @override
  void initState() {
    super.initState();
    _isDefault = widget.makeDefault;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _chooseImage() {
    ImagePickerModal.show(
      context: context,
      title: 'Select Model Photo',
      onImageSelected: (file) {
        setState(() => _selectedImage = file);
      },
    );
  }

  Future<void> _saveModel() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please take or select a photo of yourself first'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isUploading = true);
    try {
      final PersonProfileModel model = await PersonProfileService.uploadPersonProfile(
        title: _titleController.text.trim(),
        imageFile: _selectedImage!,
        isDefault: _isDefault,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Person model saved to your vault!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop(model);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Add Try-On Model', style: AppTypography.headlineMedium),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Image Upload Hero Area
                _buildImagePickerBox(),

                const SizedBox(height: AppSpacing.lg),

                // Best Practices / Guidance Box
                _buildGuidanceCard(),

                const SizedBox(height: AppSpacing.xl),

                // Model Name Field
                AppTextField(
                  controller: _titleController,
                  label: 'Model Name / Pose Description *',
                  hint: 'e.g. Studio Standing Full Body',
                  prefixIcon: Icons.badge_outlined,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Please provide a title for this model';
                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.lg),

                // Set as Default Checkbox
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: AppRadius.roundedMd,
                    border: Border.all(color: AppColors.border, width: 1),
                  ),
                  child: CheckboxListTile(
                    value: _isDefault,
                    onChanged: (val) {
                      if (val != null) setState(() => _isDefault = val);
                    },
                    activeColor: AppColors.primary,
                    checkColor: Colors.white,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Set as Default Try-On Model', style: AppTypography.titleMedium),
                    subtitle: Text(
                      'AI simulator will automatically fit garments on this model',
                      style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xxl),

                // Submit Button
                AppButton.primary(
                  text: 'Save Model to Vault',
                  icon: Icons.cloud_upload_rounded,
                  isLoading: _isUploading,
                  size: AppButtonSize.large,
                  onPressed: _saveModel,
                ),

                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePickerBox() {
    return GestureDetector(
      onTap: _chooseImage,
      child: Container(
        height: 280,
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: AppRadius.roundedLg,
          border: Border.all(
            color: _selectedImage != null ? AppColors.primary : AppColors.border,
            width: _selectedImage != null ? 1.5 : 1.0,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: _selectedImage != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(
                    _selectedImage!,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    bottom: AppSpacing.md,
                    right: AppSpacing.md,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.75),
                        borderRadius: AppRadius.roundedPill,
                        border: Border.all(color: AppColors.border, width: 0.8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.edit, color: Colors.white, size: 14),
                          SizedBox(width: 6),
                          Text('Change Photo', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  )
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_add_alt_1_rounded,
                      size: 40,
                      color: AppColors.primaryLight,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Text(
                    'Upload Full-Body Photo',
                    style: AppTypography.titleMedium,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    'Tap to take photo or choose from gallery',
                    style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildGuidanceCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFF161928),
        borderRadius: AppRadius.roundedMd,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline_rounded, color: AppColors.accent, size: 18),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'For Best AI Fitting Results',
                style: AppTypography.labelMedium.copyWith(color: AppColors.accent, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          _buildBullet('Full-body standing posture facing the camera'),
          _buildBullet('Even, clear indoor or outdoor lighting'),
          _buildBullet('Avoid loose overcoats covering your body lines'),
        ],
      ),
    );
  }

  Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: AppColors.textSecondary)),
          Expanded(
            child: Text(
              text,
              style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
