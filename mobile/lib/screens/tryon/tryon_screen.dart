import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_constants.dart';
import '../../models/garment_model.dart';
import '../../models/tryon_session_model.dart';
import '../../services/tryon_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/image_picker_modal.dart';
import '../garments/garments_screen.dart';

class TryonScreen extends StatefulWidget {
  final GarmentModel? preselectedGarment;

  const TryonScreen({super.key, this.preselectedGarment});

  @override
  State<TryonScreen> createState() => _TryonScreenState();
}

class _TryonScreenState extends State<TryonScreen> {
  GarmentModel? _selectedGarment;
  File? _selectedPersonImage;
  bool _isCreatingSession = false;
  TryonSessionModel? _lastSession;

  @override
  void initState() {
    super.initState();
    _selectedGarment = widget.preselectedGarment;
  }

  void _pickPersonImage() {
    ImagePickerModal.show(
      context: context,
      title: 'Select Person Image',
      onImageSelected: (file) {
        setState(() => _selectedPersonImage = file);
      },
    );
  }

  void _selectGarmentFromWardrobe() async {
    final selected = await Navigator.of(context).push<GarmentModel>(
      MaterialPageRoute(
        builder: (_) => const GarmentsScreen(selectMode: true),
      ),
    );
    if (selected != null) {
      setState(() => _selectedGarment = selected);
    }
  }

  Future<void> _startTryonSession() async {
    if (_selectedPersonImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select or capture a person photo'), backgroundColor: AppColors.error),
      );
      return;
    }

    if (_selectedGarment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a garment from your wardrobe'), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _isCreatingSession = true);
    try {
      final session = await TryonService.createSession(
        garmentId: _selectedGarment!.id,
        personImage: _selectedPersonImage!,
      );

      setState(() {
        _lastSession = session;
      });

      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: AppColors.success),
                SizedBox(width: 8),
                Text('Session Created', style: TextStyle(color: AppColors.textPrimary, fontSize: 18)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Session #${session.id} status: ${session.status.toUpperCase()}',
                  style: const TextStyle(color: AppColors.primaryLight, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  session.message ?? 'Image workflow validated and session record saved in MySQL.',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 12),
                const Text(
                  'ℹ️ Note: Per Phase 1 requirements, AI virtual image synthesis will be processed in Phase 2.',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontStyle: FontStyle.italic),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK', style: TextStyle(color: AppColors.primaryLight, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isCreatingSession = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Try-On Studio', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Step 1: Choose Person & Dress',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  // Person Box
                  Expanded(
                    child: _buildImageSelectorBox(
                      title: '1. Person Photo',
                      fileImage: _selectedPersonImage,
                      onTap: _pickPersonImage,
                      emptyIcon: Icons.person_add_rounded,
                      emptyLabel: 'Select Person',
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Garment Box
                  Expanded(
                    child: _buildGarmentSelectorBox(),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              CustomButton(
                text: 'Create Try-On Session',
                isLoading: _isCreatingSession,
                icon: Icons.auto_awesome_rounded,
                onPressed: _startTryonSession,
              ),
              if (_lastSession != null) ...[
                const SizedBox(height: 28),
                const Divider(color: AppColors.border),
                const SizedBox(height: 16),
                const Text(
                  'Latest Session Status',
                  style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Session #${_lastSession!.id}', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _lastSession!.status.toUpperCase(),
                              style: const TextStyle(color: AppColors.warning, fontWeight: FontWeight.bold, fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _lastSession!.message ?? 'Ready for Phase 2 AI Model Pipeline.',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSelectorBox({
    required String title,
    required File? fileImage,
    required VoidCallback onTap,
    required IconData emptyIcon,
    required String emptyLabel,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 190,
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: fileImage != null ? AppColors.primary : AppColors.border,
                width: 1.5,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: fileImage != null
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(fileImage, fit: BoxFit.cover),
                      Positioned(
                        bottom: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text('Change', style: TextStyle(color: Colors.white, fontSize: 10)),
                        ),
                      )
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(emptyIcon, size: 36, color: AppColors.textMuted),
                      const SizedBox(height: 8),
                      Text(emptyLabel, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildGarmentSelectorBox() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('2. Dress / Cloth', style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _selectGarmentFromWardrobe,
          child: Container(
            height: 190,
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _selectedGarment != null ? AppColors.secondary : AppColors.border,
                width: 1.5,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: _selectedGarment != null
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: _selectedGarment!.imageUrl ?? '',
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: AppColors.textMuted),
                      ),
                      Positioned(
                        bottom: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text('Change', style: TextStyle(color: Colors.white, fontSize: 10)),
                        ),
                      ),
                      Positioned(
                        top: 6,
                        left: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _selectedGarment!.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      )
                    ],
                  )
                : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.checkroom_rounded, size: 36, color: AppColors.textMuted),
                      SizedBox(height: 8),
                      Text('Pick Garment', style: TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
