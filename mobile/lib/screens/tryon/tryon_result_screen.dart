import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_typography.dart';
import '../../models/tryon_session_model.dart';
import '../../widgets/buttons/app_button.dart';
import '../../widgets/feedback/app_feedback_widgets.dart';
import '../../widgets/tryon/before_after_slider.dart';

class TryonResultScreen extends StatefulWidget {
  final TryonSessionModel session;
  final VoidCallback? onTryAnotherGarment;
  final VoidCallback? onTryAnotherModel;

  const TryonResultScreen({
    super.key,
    required this.session,
    this.onTryAnotherGarment,
    this.onTryAnotherModel,
  });

  @override
  State<TryonResultScreen> createState() => _TryonResultScreenState();
}

class _TryonResultScreenState extends State<TryonResultScreen> {
  bool _showSlider = true;

  @override
  Widget build(BuildContext context) {
    final modelImgUrl = widget.session.personImageUrl ?? widget.session.personProfile?.imageUrl ?? '';
    final resultImgUrl = widget.session.resultImageUrl ?? (widget.session.results.isNotEmpty ? widget.session.results.first.resultImageUrl : null) ?? '';
    final hasComparison = modelImgUrl.isNotEmpty && resultImgUrl.isNotEmpty;

    final garmentTitle = widget.session.garment?.name ?? 'Garment #${widget.session.garmentId ?? ''}';
    final modelTitle = widget.session.personProfile?.title ?? 'Person Model';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Virtual Try-On Result', style: AppTypography.headlineMedium),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Result / Comparison View
              if (hasComparison && _showSlider)
                BeforeAfterSlider(
                  beforeImageUrl: modelImgUrl,
                  afterImageUrl: resultImgUrl,
                )
              else if (resultImgUrl.isNotEmpty)
                AspectRadioBox(
                  imageUrl: resultImgUrl,
                  label: 'AI VIRTUAL RESULT',
                )
              else
                AspectRadioBox(
                  imageUrl: modelImgUrl,
                  label: 'MODEL PENDING SYNTHESIS',
                ),

              const SizedBox(height: AppSpacing.md),

              // Toggle Comparison Mode Pill
              if (hasComparison) ...[
                Center(
                  child: GestureDetector(
                    onTap: () => setState(() => _showSlider = !_showSlider),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: AppRadius.roundedPill,
                        border: Border.all(color: AppColors.border, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _showSlider ? Icons.view_sidebar_rounded : Icons.compare_arrows_rounded,
                            size: 16,
                            color: AppColors.primaryLight,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _showSlider ? 'View Result Only' : 'Compare Before / After',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.primaryLight,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],

              // 2. Session Info Card
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: AppRadius.roundedLg,
                  border: Border.all(color: AppColors.border, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Session Overview', style: AppTypography.titleMedium),
                        AppBadge(
                          text: widget.session.status.toUpperCase(),
                          color: widget.session.status == 'completed'
                              ? AppColors.success.withValues(alpha: 0.2)
                              : AppColors.warning.withValues(alpha: 0.2),
                          textColor: widget.session.status == 'completed'
                              ? AppColors.success
                              : AppColors.warning,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const Divider(color: AppColors.divider, height: 1),
                    const SizedBox(height: AppSpacing.sm),
                    _buildMetaRow(Icons.person_pin_rounded, 'Model Avatar', modelTitle),
                    const SizedBox(height: AppSpacing.xs),
                    _buildMetaRow(Icons.checkroom_rounded, 'Garment Fitted', garmentTitle),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // 3. Actions
              Row(
                children: [
                  Expanded(
                    child: AppButton.secondary(
                      text: 'New Garment',
                      icon: Icons.checkroom_rounded,
                      onPressed: () {
                        Navigator.of(context).pop();
                        if (widget.onTryAnotherGarment != null) {
                          widget.onTryAnotherGarment!();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppButton.primary(
                      text: 'Done',
                      icon: Icons.check_rounded,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetaRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: AppSpacing.xs),
        Text('$label: ', style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.caption.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class AspectRadioBox extends StatelessWidget {
  final String imageUrl;
  final String label;

  const AspectRadioBox({
    super.key,
    required this.imageUrl,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: AppAspectRatio.tryOnResult,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: AppRadius.roundedLg,
          border: Border.all(color: AppColors.border, width: 1.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: AppColors.surfaceElevated,
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryLight),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: AppColors.surfaceElevated,
                child: const Center(
                  child: Icon(Icons.broken_image_rounded, color: AppColors.textMuted, size: 36),
                ),
              ),
            ),
            Positioned(
              top: AppSpacing.sm,
              left: AppSpacing.sm,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: AppRadius.roundedPill,
                ),
                child: Text(
                  label,
                  style: AppTypography.caption.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
