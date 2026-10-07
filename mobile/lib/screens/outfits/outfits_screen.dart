import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/feedback/app_state_views.dart';

class OutfitsScreen extends StatelessWidget {
  const OutfitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mix & Match Outfits', style: AppTypography.headlineMedium),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppColors.primaryLight),
            onPressed: () {},
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: const SafeArea(
        child: AppEmptyState(
          icon: Icons.style_outlined,
          title: 'Curate Your First Outfit',
          description: 'Combine tops, bottoms, shoes, and accessories into seamless fashion ensembles.',
          actionLabel: 'Create Outfit',
        ),
      ),
    );
  }
}
