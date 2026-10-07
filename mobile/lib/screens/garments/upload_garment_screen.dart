import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../services/garment_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/image_picker_modal.dart';

class UploadGarmentScreen extends StatefulWidget {
  const UploadGarmentScreen({super.key});

  @override
  State<UploadGarmentScreen> createState() => _UploadGarmentScreenState();
}

class _UploadGarmentScreenState extends State<UploadGarmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _selectedCategory = 'Dress';
  File? _selectedImage;
  bool _isUploading = false;

  final List<String> _categories = [
    'Dress',
    'Tops & Shirts',
    'T-Shirt',
    'Pants & Jeans',
    'Skirt',
    'Jacket & Coat',
    'Ethnic & Traditional',
    'Other'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
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
      final garment = await GarmentService.uploadGarment(
        name: _nameController.text.trim(),
        category: _selectedCategory,
        imageFile: _selectedImage!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Garment uploaded successfully!'),
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Add New Garment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GestureDetector(
                  onTap: _chooseImage,
                  child: Container(
                    height: 240,
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _selectedImage != null ? AppColors.primary : AppColors.border,
                        width: 1.5,
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
                                bottom: 12,
                                right: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.7),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.edit, color: Colors.white, size: 14),
                                      SizedBox(width: 4),
                                      Text('Change', style: TextStyle(color: Colors.white, fontSize: 12)),
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
                                  size: 40,
                                  color: AppColors.primaryLight,
                                ),
                              ),
                              const SizedBox(height: 14),
                              const Text(
                                'Tap to Take Photo or Pick Image',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 6),
                              const Text(
                                'JPG, JPEG or PNG (Max 10MB)',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                CustomTextField(
                  controller: _nameController,
                  label: 'Garment Name',
                  hint: 'e.g. Floral Summer Maxi Dress',
                  prefixIcon: Icons.label_outline_rounded,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Please provide a name';
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                const Text(
                  'Category',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCategory,
                      dropdownColor: AppColors.surface,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
                      items: _categories.map((cat) {
                        return DropdownMenuItem<String>(
                          value: cat,
                          child: Text(cat),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedCategory = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 36),
                CustomButton(
                  text: 'Upload to Wardrobe',
                  isLoading: _isUploading,
                  icon: Icons.cloud_upload_rounded,
                  onPressed: _uploadGarment,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
