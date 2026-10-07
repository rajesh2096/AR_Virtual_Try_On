import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_tokens.dart';
import '../../models/category_model.dart';
import '../../widgets/buttons/app_chip.dart';

class SubcategorySelector extends StatelessWidget {
  final List<SubcategoryModel> subcategories;
  final int? selectedSubcategoryId;
  final ValueChanged<int?> onSubcategorySelected;

  const SubcategorySelector({
    super.key,
    required this.subcategories,
    required this.selectedSubcategoryId,
    required this.onSubcategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    if (subcategories.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 32,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        scrollDirection: Axis.horizontal,
        itemCount: 1 + subcategories.length,
        separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.xs),
        itemBuilder: (context, index) {
          if (index == 0) {
            final isSelected = selectedSubcategoryId == null;
            return AppChip(
              label: 'All Items',
              isSelected: isSelected,
              onSelected: () => onSubcategorySelected(null),
            );
          }

          final sub = subcategories[index - 1];
          final isSelected = selectedSubcategoryId == sub.id;

          return AppChip(
            label: sub.name,
            activeColor: AppColors.primaryLight,
            isSelected: isSelected,
            onSelected: () => onSubcategorySelected(sub.id),
          );
        },
      ),
    );
  }
}
