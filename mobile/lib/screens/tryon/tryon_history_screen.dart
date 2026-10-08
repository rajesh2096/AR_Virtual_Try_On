import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_typography.dart';
import '../../models/tryon_session_model.dart';
import '../../services/tryon_service.dart';
import '../../widgets/feedback/app_feedback_widgets.dart';
import '../../widgets/feedback/app_state_views.dart';
import 'tryon_result_screen.dart';

class TryonHistoryScreen extends StatefulWidget {
  const TryonHistoryScreen({super.key});

  @override
  State<TryonHistoryScreen> createState() => _TryonHistoryScreenState();
}

class _TryonHistoryScreenState extends State<TryonHistoryScreen> {
  List<TryonSessionModel> _history = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await TryonService.getHistory();
      if (mounted) {
        setState(() {
          _history = list;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Try-On History', style: AppTypography.headlineMedium),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.textSecondary),
            onPressed: _loadHistory,
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const AppLoadingState(message: 'Loading your virtual fitting history...');
    }

    if (_errorMessage != null) {
      return AppErrorState(
        message: 'Could not load history. Please check your network connection.',
        onRetry: _loadHistory,
      );
    }

    if (_history.isEmpty) {
      return const AppEmptyState(
        icon: Icons.history_toggle_off_rounded,
        title: 'No Try-On History',
        description: 'Your virtual looks will be preserved here so you can review and compare them anytime.',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadHistory,
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 40),
        itemCount: _history.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (ctx, index) {
          final item = _history[index];
          final dateStr = item.createdAt != null
              ? DateFormat('MMM d, yyyy • h:mm a').format(item.createdAt!)
              : '';

          final previewImg = item.resultImageUrl ?? item.personImageUrl ?? item.personProfile?.imageUrl ?? '';

          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => TryonResultScreen(session: item)),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: AppRadius.roundedLg,
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  // Image Thumbnail
                  ClipRRect(
                    borderRadius: AppRadius.roundedMd,
                    child: Container(
                      width: 65,
                      height: 85,
                      color: AppColors.surface,
                      child: previewImg.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: previewImg,
                              fit: BoxFit.cover,
                              placeholder: (_, __) => Container(color: AppColors.surface),
                              errorWidget: (_, __, ___) => const Icon(Icons.broken_image_rounded, color: AppColors.textMuted),
                            )
                          : const Icon(Icons.person_rounded, color: AppColors.textMuted),
                    ),
                  ),

                  const SizedBox(width: AppSpacing.md),

                  // Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Session #${item.id}', style: AppTypography.titleMedium),
                            AppBadge(
                              text: item.status.toUpperCase(),
                              color: item.status == 'completed'
                                  ? AppColors.success.withValues(alpha: 0.2)
                                  : AppColors.warning.withValues(alpha: 0.2),
                              textColor: item.status == 'completed'
                                  ? AppColors.success
                                  : AppColors.warning,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Garment: ${item.garment?.name ?? 'ID #${item.garmentId ?? ''}'}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.primaryLight,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateStr,
                          style: AppTypography.caption.copyWith(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),

                  const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
