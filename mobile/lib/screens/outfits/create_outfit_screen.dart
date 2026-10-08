import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/app_haptics.dart';
import '../../models/garment_model.dart';
import '../../models/outfit_model.dart';
import '../../services/outfit_service.dart';
import '../../widgets/buttons/app_button.dart';
import '../../widgets/cards/app_card.dart';
import '../../widgets/cards/app_image_card.dart';
import 'garment_picker_screen.dart';

class CreateOutfitScreen extends StatefulWidget {
  final OutfitModel? existingOutfit;

  const CreateOutfitScreen({super.key, this.existingOutfit});

  @override
  State<CreateOutfitScreen> createState() => _CreateOutfitScreenState();
}

class _CreateOutfitScreenState extends State<CreateOutfitScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  List<GarmentModel> _selectedGarments = [];
  final Map<int, String> _slotTypeMap = {}; // garmentId -> slotType
  bool _isSaving = false;

  final List<String> _slotOptions = [
    'upper',
    'lower',
    'full_body',
    'footwear',
    'outerwear',
    'accessory',
    'head',
    'eyewear',
    'wrist',
    'neck',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingOutfit != null) {
      _titleController.text = widget.existingOutfit!.title;
      _descController.text = widget.existingOutfit!.description ?? '';
      for (final item in widget.existingOutfit!.items) {
        if (item.garment != null) {
          _selectedGarments.add(item.garment!);
          _slotTypeMap[item.garmentId] = item.slotType;
        }
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  String _inferSlotType(GarmentModel garment) {
    if (_slotTypeMap.containsKey(garment.id)) {
      return _slotTypeMap[garment.id]!;
    }
    final layer = garment.subcategory?.layerType.toLowerCase() ?? '';
    if (_slotOptions.contains(layer)) return layer;

    final cat = garment.category.toLowerCase();
    if (cat.contains('top') || cat.contains('shirt') || cat.contains('t-shirt') || cat.contains('kurti')) {
      return 'upper';
    }
    if (cat.contains('pant') || cat.contains('jean') || cat.contains('skirt') || cat.contains('short') || cat.contains('lower')) {
      return 'lower';
    }
    if (cat.contains('dress') || cat.contains('gown') || cat.contains('saree') || cat.contains('jumpsuit')) {
      return 'full_body';
    }
    if (cat.contains('shoe') || cat.contains('boot') || cat.contains('sneaker') || cat.contains('heel') || cat.contains('foot')) {
      return 'footwear';
    }
    if (cat.contains('jacket') || cat.contains('blazer') || cat.contains('coat')) {
      return 'outerwear';
    }
    return 'accessory';
  }

  Future<void> _openGarmentPicker() async {
    AppHaptics.selectionClick();
    final result = await Navigator.of(context).push<List<GarmentModel>>(
      MaterialPageRoute(
        builder: (_) => GarmentPickerScreen(
          initiallySelectedGarments: _selectedGarments,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedGarments = result;
        for (final g in _selectedGarments) {
          if (!_slotTypeMap.containsKey(g.id)) {
            _slotTypeMap[g.id] = _inferSlotType(g);
          }
        }
      });
    }
  }

  void _removeGarment(GarmentModel garment) {
    AppHaptics.lightImpact();
    setState(() {
      _selectedGarments.removeWhere((g) => g.id == garment.id);
      _slotTypeMap.remove(garment.id);
    });
  }

  Future<void> _saveOutfit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedGarments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least 1 garment for this outfit'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    AppHaptics.mediumImpact();
    setState(() => _isSaving = true);

    try {
      final itemsPayload = _selectedGarments.asMap().entries.map((entry) {
        final idx = entry.key;
        final garment = entry.value;
        final slot = _slotTypeMap[garment.id] ?? _inferSlotType(garment);
        return {
          'garment_id': garment.id,
          'slot_type': slot,
          'sort_order': idx,
        };
      }).toList();

      OutfitModel outfit;
      if (widget.existingOutfit != null) {
        outfit = await OutfitService.updateOutfit(
          id: widget.existingOutfit!.id,
          title: _titleController.text.trim(),
          description: _descController.text.trim(),
          items: itemsPayload,
        );
      } else {
        outfit = await OutfitService.createOutfit(
          title: _titleController.text.trim(),
          description: _descController.text.trim(),
          items: itemsPayload,
        );
      }

      if (mounted) {
        setState(() => _isSaving = false);
        Navigator.of(context).pop(outfit);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save outfit: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingOutfit != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Outfit' : 'Curate New Outfit', style: AppTypography.headlineMedium),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveOutfit,
            child: _isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryLight),
                  )
                : Text(
                    isEditing ? 'Update' : 'Save',
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.primaryLight,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Outfit Title
                Text('Outfit Name *', style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: AppSpacing.xs),
                TextFormField(
                  controller: _titleController,
                  style: AppTypography.bodyLarge,
                  decoration: const InputDecoration(
                    hintText: 'e.g., Casual Weekend Chic, Gala Evening...',
                    hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 13.5),
                    filled: true,
                    fillColor: AppColors.surfaceElevated,
                    border: OutlineInputBorder(borderRadius: AppRadius.roundedMd, borderSide: BorderSide(color: AppColors.border)),
                    enabledBorder: OutlineInputBorder(borderRadius: AppRadius.roundedMd, borderSide: BorderSide(color: AppColors.border)),
                    focusedBorder: OutlineInputBorder(borderRadius: AppRadius.roundedMd, borderSide: BorderSide(color: AppColors.primary, width: 1.5)),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter an outfit title';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.lg),

                // 2. Outfit Description
                Text('Style Notes & Description (Optional)', style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: AppSpacing.xs),
                TextFormField(
                  controller: _descController,
                  style: AppTypography.bodyMedium,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: 'Add styling tips, occasion details, or color pairing notes...',
                    hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 13.5),
                    filled: true,
                    fillColor: AppColors.surfaceElevated,
                    border: OutlineInputBorder(borderRadius: AppRadius.roundedMd, borderSide: BorderSide(color: AppColors.border)),
                    enabledBorder: OutlineInputBorder(borderRadius: AppRadius.roundedMd, borderSide: BorderSide(color: AppColors.border)),
                    focusedBorder: OutlineInputBorder(borderRadius: AppRadius.roundedMd, borderSide: BorderSide(color: AppColors.primary, width: 1.5)),
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                // 3. Garments Composition Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Garment Ensemble (${_selectedGarments.length})',
                      style: AppTypography.headlineMedium,
                    ),
                    TextButton.icon(
                      onPressed: _openGarmentPicker,
                      icon: const Icon(Icons.add_rounded, size: 18, color: AppColors.primaryLight),
                      label: const Text('Add Items', style: TextStyle(color: AppColors.primaryLight, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.sm),

                // Selected Garments List / Empty Box
                if (_selectedGarments.isEmpty)
                  AppCard(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    onTap: _openGarmentPicker,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.style_outlined, size: 36, color: AppColors.primaryLight),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        const Text('No Garments Selected', style: AppTypography.titleMedium),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Tap here to browse your wardrobe and compose an outfit.',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        AppButton.secondary(
                          text: 'Browse Wardrobe',
                          size: AppButtonSize.small,
                          onPressed: _openGarmentPicker,
                          isFullWidth: false,
                        ),
                      ],
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _selectedGarments.length,
                    separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final garment = _selectedGarments[index];
                      final currentSlot = _slotTypeMap[garment.id] ?? _inferSlotType(garment);

                      return AppCard(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        child: Row(
                          children: [
                            // Garment Thumbnail
                            SizedBox(
                              width: 60,
                              height: 75,
                              child: AppImageCard(
                                imageUrl: garment.imageUrl ?? '',
                                aspectRatio: AppAspectRatio.fashionCard,
                                borderRadius: AppRadius.roundedSm,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),

                            // Details & Slot Selector
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    garment.name,
                                    style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.w600, fontSize: 13.5),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  // Slot Dropdown
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceElevated,
                                      borderRadius: AppRadius.roundedSm,
                                      border: Border.all(color: AppColors.border),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: _slotOptions.contains(currentSlot) ? currentSlot : _slotOptions.first,
                                        isDense: true,
                                        dropdownColor: AppColors.surfaceElevated,
                                        style: AppTypography.caption.copyWith(color: AppColors.primaryLight, fontWeight: FontWeight.bold),
                                        items: _slotOptions.map((opt) {
                                          return DropdownMenuItem(
                                            value: opt,
                                            child: Text(opt.replaceAll('_', ' ').toUpperCase()),
                                          );
                                        }).toList(),
                                        onChanged: (newSlot) {
                                          if (newSlot != null) {
                                            setState(() => _slotTypeMap[garment.id] = newSlot);
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Remove item button
                            IconButton(
                              icon: const Icon(Icons.close_rounded, color: AppColors.textMuted, size: 20),
                              tooltip: 'Remove garment',
                              onPressed: () => _removeGarment(garment),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                const SizedBox(height: AppSpacing.xxl),

                // Primary Save Button
                AppButton.primary(
                  text: isEditing ? 'Update Outfit Ensemble' : 'Create Outfit Ensemble',
                  size: AppButtonSize.large,
                  isLoading: _isSaving,
                  onPressed: _saveOutfit,
                ),

                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
