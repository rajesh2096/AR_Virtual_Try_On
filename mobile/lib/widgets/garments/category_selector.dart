import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_tokens.dart';
import '../../models/category_model.dart';
import '../../widgets/buttons/app_chip.dart';

class CategorySelector extends StatelessWidget {
  final List<CategoryModel> categories;
  final int? selectedCategoryId;
  final ValueChanged<int?> onCategorySelected;
  final bool showFavoritesOption;
  final bool isFavoritesSelected;
  final VoidCallback? onFavoritesSelected;

  const CategorySelector({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
    this.showFavoritesOption = true,
    this.isFavoritesSelected = false,
    this.onFavoritesSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        scrollDirection: Axis.horizontal,
        itemCount: 1 + (showFavoritesOption ? 1 : 0) + categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.xs),
        itemBuilder: (context, index) {
          // "All" Chip
          if (index == 0) {
            final isSelected = selectedCategoryId == null && !isFavoritesSelected;
            return AppChip(
              label: 'All',
              isSelected: isSelected,
              onSelected: () => onCategorySelected(null),
            );
          }

          // "Favorites" Chip
          if (showFavoritesOption && index == 1) {
            return AppChip(
              label: 'Favorites',
              icon: Icons.favorite_rounded,
              activeColor: AppColors.secondary,
              isSelected: isFavoritesSelected,
              onSelected: onFavoritesSelected,
            );
          }

          // Dynamic Category Chip
          final catIndex = index - 1 - (showFavoritesOption ? 1 : 0);
          final category = categories[catIndex];
          final isSelected = selectedCategoryId == category.id && !isFavoritesSelected;

          return AppChip(
            label: category.name,
            icon: _getIconForCategory(category.slug),
            isSelected: isSelected,
            onSelected: () => onCategorySelected(category.id),
          );
        },
      ),
    );
  }

  IconData? _getIconForCategory(String slug) {
    switch (slug.toLowerCase()) {
      case 'clothing':
        return Icons.checkroom_rounded;
      case 'accessory':
        return Icons.watch_rounded;
      case 'footwear':
        return Icons.roller_skating_rounded;
      case 'headwear':
        return Icons.face_retouching_natural_rounded;
      default:
        return null;
    }
  }
}
