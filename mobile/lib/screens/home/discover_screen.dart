import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/feedback/app_feedback_widgets.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Discover Trends', style: AppTypography.headlineMedium),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded, color: AppColors.textSecondary),
            onPressed: () {},
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome / Hero Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1F1838), Color(0xFF141622)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: AppRadius.roundedLg,
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppBadge.luxury(text: 'NEW SEASON 2026'),
                    SizedBox(height: AppSpacing.sm),
                    Text(
                      'Try Before You Buy',
                      style: AppTypography.headlineLarge,
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      'Experience hyper-realistic virtual fitting with AI Try-On Studio.',
                      style: AppTypography.bodyMedium,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),
              const AppSectionHeader(
                title: 'Featured Collections',
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: AppSpacing.md),

              // Placeholder collection cards
              SizedBox(
                height: 180,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: const [
                    _TrendCard(
                      title: 'Summer Chic',
                      subtitle: 'Dresses & Tops',
                      icon: Icons.sunny_snowing,
                      gradient: [Color(0xFF2E1C38), Color(0xFF141622)],
                    ),
                    SizedBox(width: AppSpacing.md),
                    _TrendCard(
                      title: 'Urban Streetwear',
                      subtitle: 'Jackets & Jeans',
                      icon: Icons.local_fire_department_rounded,
                      gradient: [Color(0xFF182638), Color(0xFF141622)],
                    ),
                    SizedBox(width: AppSpacing.md),
                    _TrendCard(
                      title: 'Traditional Couture',
                      subtitle: 'Kurtis & Sarees',
                      icon: Icons.diamond_outlined,
                      gradient: [Color(0xFF382B18), Color(0xFF141622)],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),
              const AppSectionHeader(
                title: 'Quick Actions',
                padding: EdgeInsets.zero,
              ),
              const SizedBox(height: AppSpacing.md),

              const Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.add_photo_alternate_outlined,
                      title: 'Add Garment',
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _QuickActionCard(
                      icon: Icons.person_add_alt_1_outlined,
                      title: 'Add Model',
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrendCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;

  const _TrendCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: AppRadius.roundedLg,
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, size: 28, color: AppColors.primaryLight),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTypography.titleMedium.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(subtitle, style: AppTypography.caption),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: AppRadius.roundedMd,
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: AppRadius.roundedSm,
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              title,
              style: AppTypography.labelMedium.copyWith(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
