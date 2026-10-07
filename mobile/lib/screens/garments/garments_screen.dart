import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/app_haptics.dart';
import '../../models/category_model.dart';
import '../../models/garment_model.dart';
import '../../services/category_service.dart';
import '../../services/favorite_service.dart';
import '../../services/garment_service.dart';
import '../../widgets/feedback/app_feedback_widgets.dart';
import '../../widgets/feedback/app_state_views.dart';
import '../../widgets/garments/category_selector.dart';
import '../../widgets/garments/garment_card.dart';
import '../../widgets/garments/subcategory_selector.dart';
import 'upload_garment_screen.dart';

class GarmentsScreen extends StatefulWidget {
  final bool selectMode;
  final Function(GarmentModel)? onSelect;

  const GarmentsScreen({
    super.key,
    this.selectMode = false,
    this.onSelect,
  });

  @override
  State<GarmentsScreen> createState() => _GarmentsScreenState();
}

class _GarmentsScreenState extends State<GarmentsScreen> {
  List<GarmentModel> _garments = [];
  List<CategoryModel> _categories = [];

  bool _isLoading = true;
  String? _errorMessage;

  // Filter States
  int? _selectedCategoryId;
  int? _selectedSubcategoryId;
  bool _isFavoritesSelected = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final categoriesFuture = CategoryService.getCategories();
      final garmentsFuture = GarmentService.getGarments();

      final results = await Future.wait([categoriesFuture, garmentsFuture]);
      if (mounted) {
        setState(() {
          _categories = results[0] as List<CategoryModel>;
          _garments = results[1] as List<GarmentModel>;
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

  Future<void> _loadGarments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      List<GarmentModel> list;
      if (_isFavoritesSelected) {
        list = await FavoriteService.getFavorites();
      } else {
        list = await GarmentService.getGarments(
          subcategoryId: _selectedSubcategoryId,
        );
      }

      if (mounted) {
        setState(() {
          _garments = list;
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

  void _onCategorySelected(int? categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
      _selectedSubcategoryId = null;
      _isFavoritesSelected = false;
    });
    _loadGarments();
  }

  void _onSubcategorySelected(int? subcategoryId) {
    setState(() {
      _selectedSubcategoryId = subcategoryId;
    });
    _loadGarments();
  }

  void _onFavoritesSelected() {
    setState(() {
      _isFavoritesSelected = true;
      _selectedCategoryId = null;
      _selectedSubcategoryId = null;
    });
    _loadGarments();
  }

  Future<void> _toggleFavorite(GarmentModel garment) async {
    final oldStatus = garment.isFavorite;
    final newStatus = !oldStatus;

    // Optimistic UI Update
    setState(() {
      final idx = _garments.indexWhere((g) => g.id == garment.id);
      if (idx != -1) {
        _garments[idx] = garment.copyWith(isFavorite: newStatus);
      }
    });

    try {
      await FavoriteService.toggleFavorite(garment.id, oldStatus);
    } catch (e) {
      // Rollback on failure
      if (mounted) {
        setState(() {
          final idx = _garments.indexWhere((g) => g.id == garment.id);
          if (idx != -1) {
            _garments[idx] = garment.copyWith(isFavorite: oldStatus);
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update favorite: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _deleteGarment(GarmentModel garment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Remove from Wardrobe', style: AppTypography.headlineMedium),
        content: Text(
          'Are you sure you want to remove "${garment.name}" from your active closet?',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Remove', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await GarmentService.deleteGarment(garment.id);
        _loadGarments();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Garment removed from wardrobe'), backgroundColor: AppColors.success),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to remove: $e'), backgroundColor: AppColors.error),
          );
        }
      }
    }
  }

  List<SubcategoryModel> get _currentSubcategories {
    if (_selectedCategoryId == null) return [];
    final category = _categories.firstWhere(
      (c) => c.id == _selectedCategoryId,
      orElse: () => CategoryModel(id: -1, name: '', slug: '', superType: '', sortOrder: 0, isActive: true),
    );
    return category.subcategories;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.selectMode ? 'Select Garment' : 'My Wardrobe',
          style: AppTypography.headlineMedium,
        ),
        actions: [
          if (!widget.selectMode)
            IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primaryLight, size: 24),
              tooltip: 'Add Garment',
              onPressed: () async {
                AppHaptics.selectionClick();
                final res = await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const UploadGarmentScreen()),
                );
                if (res != null) {
                  _loadGarments();
                }
              },
            ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.textSecondary),
            tooltip: 'Refresh',
            onPressed: _loadGarments,
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category Taxonomy Filter Row
          if (_categories.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            CategorySelector(
              categories: _categories,
              selectedCategoryId: _selectedCategoryId,
              isFavoritesSelected: _isFavoritesSelected,
              onCategorySelected: _onCategorySelected,
              onFavoritesSelected: _onFavoritesSelected,
            ),
          ],

          // Subcategory Row (if a category is active)
          if (_currentSubcategories.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            SubcategorySelector(
              subcategories: _currentSubcategories,
              selectedSubcategoryId: _selectedSubcategoryId,
              onSubcategorySelected: _onSubcategorySelected,
            ),
          ],

          const SizedBox(height: AppSpacing.sm),

          // Count & Header Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _isFavoritesSelected
                      ? 'Favorites (${_garments.length})'
                      : '${_garments.length} ${_garments.length == 1 ? 'Garment' : 'Garments'}',
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_isFavoritesSelected)
                  const AppBadge(
                    text: 'FAVORITES',
                    color: Color(0xFF2A1B22),
                    textColor: AppColors.secondary,
                    icon: Icons.favorite_rounded,
                  ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xs),

          // Garments Content Grid
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const AppLoadingState(message: 'Curating your wardrobe...');
    }

    if (_errorMessage != null) {
      return AppErrorState(
        message: 'Could not connect to your digital closet. Check your network connection.',
        onRetry: _loadGarments,
      );
    }

    if (_garments.isEmpty) {
      if (_isFavoritesSelected) {
        return AppEmptyState(
          icon: Icons.favorite_border_rounded,
          title: 'No Favorites Yet',
          description: 'Tap the heart icon on any garment to collect your top styling choices.',
          actionLabel: 'Browse All Garments',
          onAction: () => _onCategorySelected(null),
        );
      }

      return AppEmptyState(
        icon: Icons.checkroom_outlined,
        title: 'Your Wardrobe is Empty',
        description: 'Capture or upload clothing photos to start trying them on with AI.',
        actionLabel: 'Add First Garment',
        onAction: () async {
          final res = await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const UploadGarmentScreen()),
          );
          if (res != null) {
            _loadGarments();
          }
        },
      );
    }

    return RefreshIndicator(
      onRefresh: _loadGarments,
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 90),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: AppAspectRatio.fashionCard,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
        ),
        itemCount: _garments.length,
        itemBuilder: (ctx, index) {
          final garment = _garments[index];
          return GarmentCard(
            garment: garment,
            selectMode: widget.selectMode,
            onTap: () {
              if (widget.selectMode) {
                if (widget.onSelect != null) {
                  widget.onSelect!(garment);
                }
                Navigator.of(context).pop(garment);
              }
            },
            onFavoriteToggle: () => _toggleFavorite(garment),
            onDelete: () => _deleteGarment(garment),
          );
        },
      ),
    );
  }
}
