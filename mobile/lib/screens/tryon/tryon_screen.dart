import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/app_haptics.dart';
import '../../models/garment_model.dart';
import '../../models/person_profile_model.dart';
import '../../models/tryon_session_model.dart';
import '../../services/garment_service.dart';
import '../../services/person_profile_service.dart';
import '../../services/tryon_service.dart';
import '../../widgets/buttons/app_button.dart';
import '../../widgets/cards/app_card.dart';
import '../../widgets/cards/app_image_card.dart';
import '../../widgets/feedback/app_feedback_widgets.dart';
import '../../widgets/feedback/app_state_views.dart';
import '../garments/garments_screen.dart';
import '../profile/model_vault_screen.dart';
import 'tryon_history_screen.dart';
import 'tryon_result_screen.dart';

class TryonScreen extends StatefulWidget {
  final GarmentModel? preselectedGarment;

  const TryonScreen({super.key, this.preselectedGarment});

  @override
  State<TryonScreen> createState() => _TryonScreenState();
}

class _TryonScreenState extends State<TryonScreen> {
  PersonProfileModel? _selectedModel;
  GarmentModel? _selectedGarment;
  List<TryonSessionModel> _recentHistory = [];

  bool _isLoadingInitial = true;
  bool _isProcessing = false;
  String _tryonMode = 'single'; // 'single' or 'outfit'

  @override
  void initState() {
    super.initState();
    _selectedGarment = widget.preselectedGarment;
    _loadStudioData();
  }

  Future<void> _loadStudioData() async {
    setState(() => _isLoadingInitial = true);
    try {
      final modelsFuture = PersonProfileService.getPersonProfiles();
      final garmentsFuture = GarmentService.getGarments();
      final historyFuture = TryonService.getHistory();

      final results = await Future.wait([modelsFuture, garmentsFuture, historyFuture]);

      final models = results[0] as List<PersonProfileModel>;
      final garments = results[1] as List<GarmentModel>;
      final history = results[2] as List<TryonSessionModel>;

      if (mounted) {
        setState(() {
          // Select default model if not set
          _selectedModel = models.where((m) => m.isDefault).firstOrNull ?? (models.isNotEmpty ? models.first : null);

          // Select garment if none preselected
          if (_selectedGarment == null && garments.isNotEmpty) {
            _selectedGarment = garments.first;
          }

          _recentHistory = history.take(4).toList();
          _isLoadingInitial = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingInitial = false);
    }
  }

  void _chooseModel() async {
    AppHaptics.selectionClick();
    final model = await Navigator.of(context).push<PersonProfileModel>(
      MaterialPageRoute(builder: (_) => const ModelVaultScreen(selectMode: true)),
    );
    if (model != null) {
      setState(() => _selectedModel = model);
    }
  }

  void _chooseGarment() async {
    AppHaptics.selectionClick();
    final garment = await Navigator.of(context).push<GarmentModel>(
      MaterialPageRoute(builder: (_) => const GarmentsScreen(selectMode: true)),
    );
    if (garment != null) {
      setState(() => _selectedGarment = garment);
    }
  }

  Future<void> _startTryonProcess() async {
    if (_selectedModel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an Avatar Model from your Model Vault first'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedGarment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a Garment from your Wardrobe first'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    AppHaptics.mediumImpact();
    setState(() => _isProcessing = true);

    try {
      final session = await TryonService.createSessionWithModel(
        garmentId: _selectedGarment!.id,
        personProfileId: _selectedModel!.id,
      );

      // Refresh recent sessions
      _loadRecentHistory();

      if (mounted) {
        setState(() => _isProcessing = false);

        // Open Result / Comparison screen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TryonResultScreen(
              session: session,
              onTryAnotherGarment: _chooseGarment,
              onTryAnotherModel: _chooseModel,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _loadRecentHistory() async {
    try {
      final history = await TryonService.getHistory();
      if (mounted) {
        setState(() {
          _recentHistory = history.take(4).toList();
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_isProcessing) {
      return _buildProcessingOverlay();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('AI Try-On Studio', style: AppTypography.headlineMedium),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded, color: AppColors.textSecondary),
            tooltip: 'Try-On History',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TryonHistoryScreen()),
              );
            },
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: _isLoadingInitial
          ? const AppLoadingState(message: 'Initializing AI Studio...')
          : SafeArea(
              child: SingleChildScrollView(
                padding: AppSpacing.screenPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Interactive Dual Preview Hero Area
                    _buildDualPreviewArea(),

                    const SizedBox(height: AppSpacing.lg),

                    // 2. Mode Selector (Single Item vs Outfit)
                    _buildModeSelector(),

                    const SizedBox(height: AppSpacing.xl),

                    // 3. Selection Cards: Model & Garment
                    _buildSelectionPanels(),

                    const SizedBox(height: AppSpacing.xxl),

                    // 4. Primary ✨ TRY ON CTA Button
                    AppButton.primary(
                      text: '✨ Generate Virtual Look',
                      size: AppButtonSize.large,
                      onPressed: _startTryonProcess,
                    ),

                    const SizedBox(height: AppSpacing.xxl),

                    // 5. Recent Try-Ons
                    if (_recentHistory.isNotEmpty) ...[
                      AppSectionHeader(
                        title: 'Recent Virtual Looks',
                        actionLabel: 'View All',
                        onAction: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const TryonHistoryScreen()),
                          );
                        },
                        padding: EdgeInsets.zero,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildRecentHistoryRow(),
                    ],

                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDualPreviewArea() {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: AppRadius.roundedLg,
        border: Border.all(color: AppColors.border, width: 1.2),
      ),
      child: Row(
        children: [
          // Left: Model Preview
          Expanded(
            child: GestureDetector(
              onTap: _chooseModel,
              child: ClipRRect(
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(18)),
                child: Container(
                  color: AppColors.surface,
                  child: _selectedModel != null
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            AppImageCard(
                              imageUrl: _selectedModel!.imageUrl ?? '',
                              aspectRatio: AppAspectRatio.personModel,
                              borderRadius: BorderRadius.zero,
                            ),
                            Positioned(
                              top: 8,
                              left: 8,
                              child: _selectedModel!.isDefault
                                  ? const AppBadge.luxury(text: 'DEFAULT')
                                  : Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.6),
                                        borderRadius: AppRadius.roundedPill,
                                      ),
                                      child: const Text('MODEL', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                                    ),
                            ),
                          ],
                        )
                      : _buildEmptySelectorBox(
                          icon: Icons.person_add_alt_1_rounded,
                          label: 'Select Model',
                        ),
                ),
              ),
            ),
          ),

          // Center Connector Icon
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.5),
                  blurRadius: 10,
                ),
              ],
            ),
            child: const Icon(Icons.add, size: 18, color: Colors.white),
          ),

          // Right: Garment Preview
          Expanded(
            child: GestureDetector(
              onTap: _chooseGarment,
              child: ClipRRect(
                borderRadius: const BorderRadius.horizontal(right: Radius.circular(18)),
                child: Container(
                  color: AppColors.surface,
                  child: _selectedGarment != null
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            AppImageCard(
                              imageUrl: _selectedGarment!.imageUrl ?? '',
                              aspectRatio: AppAspectRatio.fashionCard,
                              borderRadius: BorderRadius.zero,
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.85),
                                  borderRadius: AppRadius.roundedPill,
                                ),
                                child: Text(
                                  (_selectedGarment!.subcategory?.name ?? _selectedGarment!.category).toUpperCase(),
                                  style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        )
                      : _buildEmptySelectorBox(
                          icon: Icons.checkroom_rounded,
                          label: 'Select Garment',
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySelectorBox({required IconData icon, required String label}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 32, color: AppColors.textMuted),
        const SizedBox(height: 6),
        Text(label, style: AppTypography.caption.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildModeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: AppRadius.roundedPill,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _tryonMode = 'single'),
              child: AnimatedContainer(
                duration: AppDurations.fast,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _tryonMode == 'single' ? AppColors.primary : Colors.transparent,
                  borderRadius: AppRadius.roundedPill,
                ),
                child: Center(
                  child: Text(
                    'Single Garment Fit',
                    style: AppTypography.labelMedium.copyWith(
                      color: _tryonMode == 'single' ? Colors.white : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Multi-garment Outfit try-on mode is coming next in Phase 4!'),
                    backgroundColor: AppColors.surfaceElevated,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: AppRadius.roundedPill,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Mix & Match Outfit',
                      style: AppTypography.labelMedium.copyWith(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const AppBadge(text: 'SOON', color: Color(0xFF1E2132), textColor: AppColors.textSecondary),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionPanels() {
    return Column(
      children: [
        // Model Selection Row
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          onTap: _chooseModel,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_pin_rounded, color: AppColors.primaryLight, size: 22),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Person Model', style: AppTypography.caption),
                    Text(
                      _selectedModel?.title ?? 'Tap to select avatar model',
                      style: AppTypography.titleMedium.copyWith(
                        color: _selectedModel != null ? AppColors.textPrimary : AppColors.primaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // Garment Selection Row
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          onTap: _chooseGarment,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.checkroom_rounded, color: AppColors.secondary, size: 22),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Garment Selection', style: AppTypography.caption),
                    Text(
                      _selectedGarment?.name ?? 'Tap to select garment from wardrobe',
                      style: AppTypography.titleMedium.copyWith(
                        color: _selectedGarment != null ? AppColors.textPrimary : AppColors.secondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecentHistoryRow() {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _recentHistory.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) {
          final session = _recentHistory[index];
          final imgUrl = session.resultImageUrl ?? session.personImageUrl ?? session.personProfile?.imageUrl ?? '';

          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => TryonResultScreen(session: session)),
              );
            },
            child: Container(
              width: 90,
              decoration: BoxDecoration(
                borderRadius: AppRadius.roundedMd,
                border: Border.all(color: AppColors.border),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  imgUrl.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: imgUrl,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Container(color: AppColors.surface),
                        )
                      : Container(color: AppColors.surfaceElevated),
                  Positioned(
                    bottom: 4,
                    left: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.7),
                        borderRadius: AppRadius.roundedPill,
                      ),
                      child: Text(
                        '#${session.id}',
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProcessingOverlay() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Center(
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              const Text(
                'Synthesizing Look...',
                style: AppTypography.displayMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Warping garment contours to your 3D avatar pose.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.xxl),
              const AppBadge.luxury(text: 'AI PIPELINE ACTIVE'),
            ],
          ),
        ),
      ),
    );
  }
}
