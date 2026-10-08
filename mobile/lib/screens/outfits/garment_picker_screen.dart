import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/app_haptics.dart';
import '../../models/category_model.dart';
import '../../models/garment_model.dart';
import '../../services/category_service.dart';
import '../../services/garment_service.dart';
import '../../widgets/buttons/app_button.dart';
import '../../widgets/cards/app_image_card.dart';
import '../../widgets/feedback/app_state_views.dart';
import '../../widgets/garments/category_selector.dart';

class GarmentPickerScreen extends StatefulWidget {
  final List<GarmentModel> initiallySelectedGarments;

  const GarmentPickerScreen({
    super.key,
    this.initiallySelectedGarments = const [],
  });

  @override
  State<GarmentPickerScreen> createState() => _GarmentPickerScreenState();
}

class _GarmentPickerScreenState extends State<GarmentPickerScreen> {
  List<GarmentModel> _allGarments = [];
  List<GarmentModel> _filteredGarments = [];
  List<CategoryModel> _categories = [];
  final Set<int> _selectedGarmentIds = {};
  final Map<int, GarmentModel> _selectedGarmentsMap = {};

  bool _isLoading = true;
  String? _errorMessage;
  int? _selectedCategoryId;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    for (final g in widget.initiallySelectedGarments) {
      _selectedGarmentIds.add(g.id);
      _selectedGarmentsMap[g.id] = g;
    }
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
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
          _allGarments = results[1] as List<GarmentModel>;
          for (final g in _allGarments) {
            if (_selectedGarmentIds.contains(g.id)) {
              _selectedGarmentsMap[g.id] = g;
            }
          }
          _applyFilter();
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

  void _applyFilter() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      _filteredGarments = _allGarments.where((g) {
        // Category filter
        if (_selectedCategoryId != null) {
          final cat = _categories.firstWhere(
            (c) => c.id == _selectedCategoryId,
            orElse: () => CategoryModel(id: -1, name: '', slug: '', superType: '', sortOrder: 0, isActive: true),
          );
          final matchesCategory = g.category.toLowerCase() == cat.slug.toLowerCase() ||
              g.category.toLowerCase() == cat.name.toLowerCase() ||
              cat.subcategories.any((s) => s.id == g.subcategoryId);
          if (!matchesCategory) return false;
        }

        // Search query
        if (query.isNotEmpty) {
          final matchesName = g.name.toLowerCase().contains(query);
          final matchesBrand = (g.brand ?? '').toLowerCase().contains(query);
          final matchesStyle = (g.style ?? '').toLowerCase().contains(query);
          if (!matchesName && !matchesBrand && !matchesStyle) return false;
        }

        return true;
      }).toList();
    });
  }

  void _toggleGarmentSelection(GarmentModel garment) {
    AppHaptics.selectionClick();
    setState(() {
      if (_selectedGarmentIds.contains(garment.id)) {
        _selectedGarmentIds.remove(garment.id);
        _selectedGarmentsMap.remove(garment.id);
      } else {
        _selectedGarmentIds.add(garment.id);
        _selectedGarmentsMap[garment.id] = garment;
      }
    });
  }

  void _confirmSelection() {
    AppHaptics.mediumImpact();
    Navigator.of(context).pop(_selectedGarmentsMap.values.toList());
  }

  @override
  Widget build(BuildContext context) {
    final selectedCount = _selectedGarmentIds.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Select Garments', style: AppTypography.headlineMedium),
        actions: [
          if (selectedCount > 0)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: AppSpacing.md),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: AppRadius.roundedPill,
                  ),
                  child: Text(
                    '$selectedCount Selected',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Search Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => _applyFilter(),
              style: AppTypography.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Search garments by name, brand, style...',
                hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded, color: AppColors.textSecondary, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          _applyFilter();
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surfaceElevated,
                contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                border: const OutlineInputBorder(
                  borderRadius: AppRadius.roundedMd,
                  borderSide: BorderSide(color: AppColors.border),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderRadius: AppRadius.roundedMd,
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderRadius: AppRadius.roundedMd,
                  borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
          ),

          // Categories Filter Row
          if (_categories.isNotEmpty) ...[
            CategorySelector(
              categories: _categories,
              selectedCategoryId: _selectedCategoryId,
              isFavoritesSelected: false,
              onCategorySelected: (catId) {
                setState(() => _selectedCategoryId = catId);
                _applyFilter();
              },
              onFavoritesSelected: () {},
            ),
            const SizedBox(height: AppSpacing.sm),
          ],

          // Content Grid
          Expanded(
            child: _buildGridContent(),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.md,
          bottom: MediaQuery.of(context).padding.bottom + AppSpacing.md,
        ),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: AppButton.primary(
          text: selectedCount == 0 ? 'Done (0 items)' : 'Add $selectedCount ${selectedCount == 1 ? 'Garment' : 'Garments'}',
          onPressed: _confirmSelection,
          size: AppButtonSize.large,
        ),
      ),
    );
  }

  Widget _buildGridContent() {
    if (_isLoading) {
      return const AppLoadingState(message: 'Loading wardrobe garments...');
    }

    if (_errorMessage != null) {
      return AppErrorState(
        message: 'Could not load garments. Check connection.',
        onRetry: _loadData,
      );
    }

    if (_filteredGarments.isEmpty) {
      return AppEmptyState(
        icon: Icons.checkroom_outlined,
        title: 'No Matching Garments',
        description: _allGarments.isEmpty
            ? 'Your wardrobe is empty. Add garments first.'
            : 'Try adjusting your search or category filter.',
        actionLabel: _allGarments.isNotEmpty ? 'Reset Filters' : null,
        onAction: _allGarments.isNotEmpty
            ? () {
                _searchController.clear();
                setState(() => _selectedCategoryId = null);
                _applyFilter();
              }
            : null,
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.xs, AppSpacing.lg, AppSpacing.lg),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: AppAspectRatio.fashionCard,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
      ),
      itemCount: _filteredGarments.length,
      itemBuilder: (context, index) {
        final garment = _filteredGarments[index];
        final isSelected = _selectedGarmentIds.contains(garment.id);

        return GestureDetector(
          onTap: () => _toggleGarmentSelection(garment),
          child: Stack(
            fit: StackFit.expand,
            children: [
              AppImageCard(
                imageUrl: garment.imageUrl ?? '',
                aspectRatio: AppAspectRatio.fashionCard,
                isSelected: isSelected,
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
                      garment.subcategory?.name ?? garment.category,
                      style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Selection Checkmark Overlay
              Positioned(
                top: AppSpacing.sm,
                right: AppSpacing.sm,
                child: AnimatedContainer(
                  duration: AppDurations.fast,
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.black.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? Colors.white : AppColors.border,
                      width: 1.5,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                      : null,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
