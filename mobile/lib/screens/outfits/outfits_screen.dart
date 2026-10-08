import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/app_haptics.dart';
import '../../models/outfit_model.dart';
import '../../services/outfit_service.dart';
import '../../widgets/cards/app_card.dart';
import '../../widgets/cards/app_image_card.dart';
import '../../widgets/feedback/app_feedback_widgets.dart';
import '../../widgets/feedback/app_state_views.dart';
import 'create_outfit_screen.dart';
import 'outfit_detail_screen.dart';

class OutfitsScreen extends StatefulWidget {
  const OutfitsScreen({super.key});

  @override
  State<OutfitsScreen> createState() => _OutfitsScreenState();
}

class _OutfitsScreenState extends State<OutfitsScreen> {
  List<OutfitModel> _outfits = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadOutfits();
  }

  Future<void> _loadOutfits() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final outfits = await OutfitService.getOutfits();
      if (mounted) {
        setState(() {
          _outfits = outfits;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _openCreateOutfit() async {
    AppHaptics.selectionClick();
    final result = await Navigator.of(context).push<OutfitModel>(
      MaterialPageRoute(builder: (_) => const CreateOutfitScreen()),
    );

    if (result != null && mounted) {
      _loadOutfits();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Created outfit "${result.title}"'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _openOutfitDetail(OutfitModel outfit) async {
    AppHaptics.lightImpact();
    final deleted = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => OutfitDetailScreen(outfit: outfit),
      ),
    );

    if (deleted == true && mounted) {
      _loadOutfits();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Outfit deleted'), backgroundColor: AppColors.surfaceElevated),
      );
    } else {
      _loadOutfits();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mix & Match Outfits', style: AppTypography.headlineMedium),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primaryLight, size: 24),
            tooltip: 'Create Outfit',
            onPressed: _openCreateOutfit,
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.textSecondary),
            tooltip: 'Refresh',
            onPressed: _loadOutfits,
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: SafeArea(
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const AppLoadingState(message: 'Loading your curated ensembles...');
    }

    if (_errorMessage != null) {
      return AppErrorState(
        message: 'Could not connect to outfit wardrobe. Please check network.',
        onRetry: _loadOutfits,
      );
    }

    if (_outfits.isEmpty) {
      return AppEmptyState(
        icon: Icons.style_outlined,
        title: 'Curate Your First Outfit',
        description: 'Combine tops, bottoms, shoes, and accessories into seamless fashion ensembles.',
        actionLabel: 'Create Outfit',
        onAction: _openCreateOutfit,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOutfits,
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 90),
        itemCount: _outfits.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, index) {
          final outfit = _outfits[index];
          return _buildOutfitCard(outfit);
        },
      ),
    );
  }

  Widget _buildOutfitCard(OutfitModel outfit) {
    final validItems = outfit.items.where((i) => i.garment != null).toList();

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      onTap: () => _openOutfitDetail(outfit),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Title & Item Count
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  outfit.title,
                  style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              AppBadge(
                text: '${outfit.items.length} ${outfit.items.length == 1 ? 'ITEM' : 'ITEMS'}',
                color: AppColors.primary.withValues(alpha: 0.15),
                textColor: AppColors.primaryLight,
              ),
            ],
          ),

          if (outfit.description != null && outfit.description!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              outfit.description!,
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          const SizedBox(height: AppSpacing.md),

          // Garment Thumbnails Row
          if (validItems.isEmpty)
            Container(
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: AppRadius.roundedMd,
              ),
              child: const Center(
                child: Text('No garment images', style: AppTypography.caption),
              ),
            )
          else
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: validItems.length,
                separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
                itemBuilder: (context, itemIdx) {
                  final item = validItems[itemIdx];
                  final garment = item.garment!;

                  return SizedBox(
                    width: 75,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        AppImageCard(
                          imageUrl: garment.imageUrl ?? '',
                          aspectRatio: AppAspectRatio.fashionCard,
                          borderRadius: AppRadius.roundedSm,
                        ),
                        Positioned(
                          bottom: 2,
                          left: 2,
                          right: 2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.75),
                              borderRadius: AppRadius.roundedSm,
                            ),
                            child: Text(
                              item.slotType.toUpperCase(),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
