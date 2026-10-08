import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/app_haptics.dart';
import '../../models/outfit_model.dart';
import '../../services/outfit_service.dart';
import '../../widgets/buttons/app_button.dart';
import '../../widgets/cards/app_card.dart';
import '../../widgets/cards/app_image_card.dart';
import '../../widgets/feedback/app_feedback_widgets.dart';
import '../tryon/tryon_screen.dart';
import 'create_outfit_screen.dart';

class OutfitDetailScreen extends StatefulWidget {
  final OutfitModel outfit;

  const OutfitDetailScreen({super.key, required this.outfit});

  @override
  State<OutfitDetailScreen> createState() => _OutfitDetailScreenState();
}

class _OutfitDetailScreenState extends State<OutfitDetailScreen> {
  late OutfitModel _outfit;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _outfit = widget.outfit;
    _refreshOutfit();
  }

  Future<void> _refreshOutfit() async {
    try {
      final updated = await OutfitService.getOutfitById(_outfit.id);
      if (mounted) {
        setState(() => _outfit = updated);
      }
    } catch (_) {}
  }

  Future<void> _deleteOutfit() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete Outfit', style: AppTypography.headlineMedium),
        content: Text(
          'Are you sure you want to delete "${_outfit.title}"? This cannot be undone.',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      AppHaptics.mediumImpact();
      setState(() => _isLoading = true);
      try {
        await OutfitService.deleteOutfit(_outfit.id);
        if (mounted) {
          Navigator.of(context).pop(true); // Return true to indicate deleted
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete: $e'), backgroundColor: AppColors.error),
          );
        }
      }
    }
  }

  void _editOutfit() async {
    AppHaptics.selectionClick();
    final updated = await Navigator.of(context).push<OutfitModel>(
      MaterialPageRoute(
        builder: (_) => CreateOutfitScreen(existingOutfit: _outfit),
      ),
    );

    if (updated != null && mounted) {
      setState(() => _outfit = updated);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Outfit updated successfully'), backgroundColor: AppColors.success),
      );
    }
  }

  void _tryOnSingleGarment(int garmentIndex) {
    if (_outfit.items.isEmpty) return;
    final item = _outfit.items[garmentIndex];
    if (item.garment != null) {
      AppHaptics.mediumImpact();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => TryonScreen(preselectedGarment: item.garment),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_outfit.title, style: AppTypography.headlineMedium),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.primaryLight),
            tooltip: 'Edit Outfit',
            onPressed: _editOutfit,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
            tooltip: 'Delete Outfit',
            onPressed: _deleteOutfit,
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryLight))
          : SafeArea(
              child: SingleChildScrollView(
                padding: AppSpacing.screenPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Outfit Header & Info
                    AppCard(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(_outfit.title, style: AppTypography.displayMedium),
                              ),
                              AppBadge(
                                text: '${_outfit.items.length} ${_outfit.items.length == 1 ? 'ITEM' : 'ITEMS'}',
                                color: AppColors.primary.withValues(alpha: 0.2),
                                textColor: AppColors.primaryLight,
                              ),
                            ],
                          ),
                          if (_outfit.description != null && _outfit.description!.isNotEmpty) ...[
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              _outfit.description!,
                              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Try On Ensemble CTA Box
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.surfaceElevated,
                            AppColors.primary.withValues(alpha: 0.15),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: AppRadius.roundedLg,
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.auto_awesome_rounded, color: AppColors.primaryLight, size: 22),
                              SizedBox(width: AppSpacing.sm),
                              Text('Virtual Try-On', style: AppTypography.titleMedium),
                              Spacer(),
                              AppBadge.luxury(text: 'STUDIO READY'),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Select any garment below to launch in the AI Try-On Studio, or try on the primary item.',
                            style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          if (_outfit.items.isNotEmpty && _outfit.items.first.garment != null)
                            AppButton.primary(
                              text: '✨ Try On Primary (${_outfit.items.first.garment!.name})',
                              size: AppButtonSize.medium,
                              onPressed: () => _tryOnSingleGarment(0),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Garments In Outfit
                    const AppSectionHeader(
                      title: 'Included Garments',
                      padding: EdgeInsets.zero,
                    ),

                    const SizedBox(height: AppSpacing.md),

                    if (_outfit.items.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          child: Text(
                            'No garments attached to this outfit yet.',
                            style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
                          ),
                        ),
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: AppAspectRatio.fashionCard,
                          crossAxisSpacing: AppSpacing.md,
                          mainAxisSpacing: AppSpacing.md,
                        ),
                        itemCount: _outfit.items.length,
                        itemBuilder: (context, index) {
                          final item = _outfit.items[index];
                          final garment = item.garment;

                          if (garment == null) {
                            return AppCard(
                              child: Center(
                                child: Text('Garment #${item.garmentId}', style: AppTypography.caption),
                              ),
                            );
                          }

                          return Stack(
                            fit: StackFit.expand,
                            children: [
                              AppImageCard(
                                imageUrl: garment.imageUrl ?? '',
                                aspectRatio: AppAspectRatio.fashionCard,
                                onTap: () => _tryOnSingleGarment(index),
                                overlayContent: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      garment.name,
                                      style: AppTypography.titleMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item.slotType.toUpperCase(),
                                      style: AppTypography.caption.copyWith(
                                        color: AppColors.primaryLight,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Try-On Action Badge
                              Positioned(
                                top: AppSpacing.sm,
                                right: AppSpacing.sm,
                                child: GestureDetector(
                                  onTap: () => _tryOnSingleGarment(index),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.9),
                                      borderRadius: AppRadius.roundedPill,
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.auto_awesome_rounded, size: 12, color: Colors.white),
                                        SizedBox(width: 4),
                                        Text('TRY ON', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),

                    const SizedBox(height: AppSpacing.xxl),
                  ],
                ),
              ),
            ),
    );
  }
}
