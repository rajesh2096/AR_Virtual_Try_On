import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_typography.dart';
import '../../models/category_model.dart';
import '../../models/garment_model.dart';
import '../../services/category_service.dart';
import '../../services/garment_service.dart';
import '../../widgets/buttons/app_button.dart';
import '../../widgets/buttons/app_chip.dart';
import '../../widgets/inputs/app_text_field.dart';
import '../../widgets/image_picker_modal.dart';

class UploadGarmentScreen extends StatefulWidget {
  const UploadGarmentScreen({super.key});

  @override
  State<UploadGarmentScreen> createState() => _UploadGarmentScreenState();
}

class _UploadGarmentScreenState extends State<UploadGarmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _colorController = TextEditingController();
  final _sizeController = TextEditingController();
  final _styleController = TextEditingController();
  final _descController = TextEditingController();

  File? _selectedImage;
  bool _isUploading = false;
  bool _isLoadingTaxonomy = true;

  List<CategoryModel> _categories = [];
  CategoryModel? _selectedCategory;
  SubcategoryModel? _selectedSubcategory;

  @override
  void initState() {
    super.initState();
    _loadTaxonomy();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _colorController.dispose();
    _sizeController.dispose();
    _styleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _loadTaxonomy() async {
    try {
      final list = await CategoryService.getCategories();
      if (mounted) {
        setState(() {
          _categories = list;
          if (_categories.isNotEmpty) {
            _selectedCategory = _categories.first;
            if (_selectedCategory!.subcategories.isNotEmpty) {
              _selectedSubcategory = _selectedCategory!.subcategories.first;
            }
          }
          _isLoadingTaxonomy = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingTaxonomy = false);
      }
    }
  }

  void _chooseImage() {
    ImagePickerModal.show(
      context: context,
      title: 'Select Garment Photo',
      onImageSelected: (file) {
        setState(() => _selectedImage = file);
      },
    );
  }

  Future<void> _uploadGarment() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select or capture a garment image first'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isUploading = true);
    try {
      final categoryName = _selectedSubcategory?.name ?? (_selectedCategory?.name ?? 'general');

      final GarmentModel garment = await GarmentService.uploadGarment(
        name: _nameController.text.trim(),
        category: categoryName,
        subcategoryId: _selectedSubcategory?.id,
        brand: _brandController.text.trim().isEmpty ? null : _brandController.text.trim(),
        primaryColor: _colorController.text.trim().isEmpty ? null : _colorController.text.trim(),
        size: _sizeController.text.trim().isEmpty ? null : _sizeController.text.trim(),
        style: _styleController.text.trim().isEmpty ? null : _styleController.text.trim(),
        description: _descController.text.trim().isEmpty ? null : _descController.text.trim(),
        imageFile: _selectedImage!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Garment added to your wardrobe!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop(garment);
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
        title: const Text('Add Garment', style: AppTypography.headlineMedium),
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
                // Image Upload Hero Box
                _buildImagePickerBox(),

                const SizedBox(height: AppSpacing.xl),

                // Name Field
                AppTextField(
                  controller: _nameController,
                  label: 'Garment Name *',
                  hint: 'e.g. Classic Tailored Blazer',
                  prefixIcon: Icons.label_outline_rounded,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Please enter garment name';
                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.lg),

                // Category Selection
                if (!_isLoadingTaxonomy && _categories.isNotEmpty) ...[
                  Text('Category *', style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: AppSpacing.xs),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: _categories.map((cat) {
                      final isSelected = _selectedCategory?.id == cat.id;
                      return AppChip(
                        label: cat.name,
                        isSelected: isSelected,
                        onSelected: () {
                          setState(() {
                            _selectedCategory = cat;
                            _selectedSubcategory = cat.subcategories.isNotEmpty ? cat.subcategories.first : null;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Subcategory Selection
                  if (_selectedCategory != null && _selectedCategory!.subcategories.isNotEmpty) ...[
                    Text('Subcategory (Style Type)', style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondary)),
                    const SizedBox(height: AppSpacing.xs),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: _selectedCategory!.subcategories.map((sub) {
                        final isSelected = _selectedSubcategory?.id == sub.id;
                        return AppChip(
                          label: sub.name,
                          activeColor: AppColors.primaryLight,
                          isSelected: isSelected,
                          onSelected: () {
                            setState(() => _selectedSubcategory = sub);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ],

                // Metadata Fields: Brand & Color
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _brandController,
                        label: 'Brand (Optional)',
                        hint: 'Zara, Gucci...',
                        prefixIcon: Icons.storefront_outlined,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: AppTextField(
                        controller: _colorController,
                        label: 'Primary Color',
                        hint: 'Black, Navy...',
                        prefixIcon: Icons.palette_outlined,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.md),

                // Metadata Fields: Size & Style
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _sizeController,
                        label: 'Size (Optional)',
                        hint: 'S, M, L, 32...',
                        prefixIcon: Icons.straighten_rounded,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: AppTextField(
                        controller: _styleController,
                        label: 'Style (Optional)',
                        hint: 'Casual, Formal...',
                        prefixIcon: Icons.auto_fix_high_rounded,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.md),

                // Description Field
                AppTextField(
                  controller: _descController,
                  label: 'Notes / Description',
                  hint: 'Fits slim, perfect for evening wear...',
                  maxLines: 2,
                  prefixIcon: Icons.notes_rounded,
                ),

                const SizedBox(height: AppSpacing.xxl),

                // Submit Button
                AppButton.primary(
                  text: 'Save to Wardrobe',
                  icon: Icons.cloud_upload_rounded,
                  isLoading: _isUploading,
                  size: AppButtonSize.large,
                  onPressed: _uploadGarment,
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
        height: 240,
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
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_photo_alternate_rounded,
                      size: 36,
                      color: AppColors.primaryLight,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Text(
                    'Upload Garment Photo',
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
}
