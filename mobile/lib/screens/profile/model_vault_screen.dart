import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/app_haptics.dart';
import '../../models/person_profile_model.dart';
import '../../services/person_profile_service.dart';
import '../../widgets/feedback/app_state_views.dart';
import '../../widgets/person_models/person_model_card.dart';
import 'add_model_screen.dart';

class ModelVaultScreen extends StatefulWidget {
  final bool selectMode;
  final Function(PersonProfileModel)? onSelect;

  const ModelVaultScreen({
    super.key,
    this.selectMode = false,
    this.onSelect,
  });

  @override
  State<ModelVaultScreen> createState() => _ModelVaultScreenState();
}

class _ModelVaultScreenState extends State<ModelVaultScreen> {
  List<PersonProfileModel> _models = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadModels();
  }

  Future<void> _loadModels() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await PersonProfileService.getPersonProfiles();
      if (mounted) {
        setState(() {
          _models = list;
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

  Future<void> _setDefaultModel(PersonProfileModel model) async {
    if (model.isDefault) return;

    AppHaptics.mediumImpact();

    // Optimistic UI Update
    setState(() {
      _models = _models.map((m) {
        return m.copyWith(isDefault: m.id == model.id);
      }).toList();
    });

    try {
      await PersonProfileService.setDefaultPersonProfile(model.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${model.title}" is now your default Try-On model'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      // Revert from server
      _loadModels();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update default model: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _deleteModel(PersonProfileModel model) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete Model Avatar', style: AppTypography.headlineMedium),
        content: Text(
          'Are you sure you want to delete "${model.title}"? Your past virtual try-on images will remain saved.',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await PersonProfileService.deletePersonProfile(model.id);
        _loadModels();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Model deleted successfully'), backgroundColor: AppColors.success),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete model: $e'), backgroundColor: AppColors.error),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.selectMode ? 'Select Try-On Model' : 'Model Vault',
          style: AppTypography.headlineMedium,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primaryLight, size: 24),
            tooltip: 'Add Model',
            onPressed: () async {
              AppHaptics.selectionClick();
              final res = await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AddModelScreen()),
              );
              if (res != null) {
                _loadModels();
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.textSecondary),
            tooltip: 'Refresh',
            onPressed: _loadModels,
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const AppLoadingState(message: 'Opening your avatar vault...');
    }

    if (_errorMessage != null) {
      return AppErrorState(
        message: 'Unable to load models from server. Check your connection.',
        onRetry: _loadModels,
      );
    }

    if (_models.isEmpty) {
      return AppEmptyState(
        icon: Icons.person_add_alt_1_outlined,
        title: 'No Person Models Yet',
        description: 'Upload a clear full-body photo of yourself to generate realistic AI virtual fittings.',
        actionLabel: 'Add First Model',
        onAction: () async {
          final res = await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddModelScreen(makeDefault: true)),
          );
          if (res != null) {
            _loadModels();
          }
        },
      );
    }

    final defaultModel = _models.where((m) => m.isDefault).firstOrNull;

    return RefreshIndicator(
      onRefresh: _loadModels,
      color: AppColors.primary,
      backgroundColor: AppColors.surface,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 90),
        children: [
          // Information Banner
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1B1A2E), Color(0xFF141622)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: AppRadius.roundedLg,
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.auto_awesome_rounded, color: AppColors.primaryLight, size: 22),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Virtual Fitting Avatar', style: AppTypography.titleMedium),
                      const SizedBox(height: 2),
                      Text(
                        'Your default model is automatically selected when trying on dresses.',
                        style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Count & Status Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_models.length} ${_models.length == 1 ? 'Model' : 'Models'} Saved',
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (defaultModel != null)
                Text(
                  'Default: ${defaultModel.title}',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // 2-Column Responsive Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: AppAspectRatio.personModel,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
            ),
            itemCount: _models.length,
            itemBuilder: (ctx, index) {
              final model = _models[index];
              return PersonModelCard(
                model: model,
                selectMode: widget.selectMode,
                onTap: () {
                  if (widget.selectMode) {
                    if (widget.onSelect != null) {
                      widget.onSelect!(model);
                    }
                    Navigator.of(context).pop(model);
                  }
                },
                onSetDefault: () => _setDefaultModel(model),
                onDelete: () => _deleteModel(model),
              );
            },
          ),
        ],
      ),
    );
  }
}
