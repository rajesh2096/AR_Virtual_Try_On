import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/config/app_config.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/app_haptics.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/person_profile_service.dart';
import '../../widgets/buttons/app_button.dart';
import '../../widgets/cards/app_avatar.dart';
import '../../widgets/cards/app_card.dart';
import '../../widgets/inputs/app_text_field.dart';
import '../auth/login_screen.dart';
import 'model_vault_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _user;
  int _modelsCount = 0;
  String? _defaultModelName;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);
    try {
      final user = await AuthService.getCurrentUser();
      final models = await PersonProfileService.getPersonProfiles();
      final defaultModel = models.where((m) => m.isDefault).firstOrNull;

      if (mounted) {
        setState(() {
          _user = user;
          _modelsCount = models.length;
          _defaultModelName = defaultModel?.title;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Sign Out', style: AppTypography.headlineMedium),
        content: const Text('Are you sure you want to sign out of your account?', style: AppTypography.bodyMedium),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Sign Out', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await AuthService.logout();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  void _showServerSettings() {
    final serverController = TextEditingController(text: AppConfig.baseUrl);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheetRadius),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.xl,
          right: AppSpacing.xl,
          top: AppSpacing.xl,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Backend Server URL',
              style: AppTypography.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'Configures where this app connects for API & Uploads.',
              style: AppTypography.caption,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              controller: serverController,
              label: 'Server URL',
              hint: 'http://10.0.2.2:8000',
              prefixIcon: Icons.dns_rounded,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton.primary(
              text: 'Save & Test Connection',
              onPressed: () async {
                final url = serverController.text.trim();
                AppConfig.updateBaseUrl(url);
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString(AppConstants.customServerUrlKey, url);

                final healthy = await AuthService.checkBackendHealth();
                if (!ctx.mounted) return;
                Navigator.of(ctx).pop();
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(healthy ? 'Backend is online & reachable!' : 'Server URL updated, but health check failed at $url'),
                    backgroundColor: healthy ? AppColors.success : AppColors.warning,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Profile', style: AppTypography.headlineMedium),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.textSecondary),
            onPressed: _loadProfileData,
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppColors.primaryLight)))
          : SingleChildScrollView(
              padding: AppSpacing.screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.sm),

                  // User Header Card
                  AppCard(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Row(
                      children: [
                        AppAvatar(
                          name: _user?.name ?? 'User',
                          size: 64,
                          showBorder: true,
                          borderColor: AppColors.primary,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _user?.name ?? 'Fashion User',
                                style: AppTypography.headlineMedium,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _user?.email ?? '',
                                style: AppTypography.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Model Vault CTA Card (Feature Highlight)
                  GestureDetector(
                    onTap: () async {
                      AppHaptics.selectionClick();
                      await Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ModelVaultScreen()),
                      );
                      _loadProfileData();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2E1C38), Color(0xFF141622)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: AppRadius.roundedLg,
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4), width: 1.2),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.person_pin_rounded, color: AppColors.primaryLight, size: 28),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Text('Model Vault / Avatars', style: AppTypography.titleLarge),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: const BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius: AppRadius.roundedPill,
                                      ),
                                      child: Text(
                                        '$_modelsCount',
                                        style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _defaultModelName != null
                                      ? 'Active: $_defaultModelName'
                                      : 'Upload your standing photo for try-on',
                                  style: AppTypography.caption.copyWith(
                                    color: _defaultModelName != null ? AppColors.accent : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textSecondary),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Settings / Utilities
                  AppCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        _buildSettingsTile(
                          icon: Icons.dns_rounded,
                          title: 'Server Configuration',
                          subtitle: AppConfig.baseUrl,
                          onTap: _showServerSettings,
                        ),
                        const Divider(height: 1, color: AppColors.divider),
                        _buildSettingsTile(
                          icon: Icons.security_rounded,
                          title: 'Security & Auth',
                          subtitle: 'Encrypted token storage & JWT auth',
                          onTap: () {},
                        ),
                        const Divider(height: 1, color: AppColors.divider),
                        _buildSettingsTile(
                          icon: Icons.info_outline_rounded,
                          title: 'Application Version',
                          subtitle: 'AI Virtual Try-On v2.0 (Phase 3)',
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  // Logout Button
                  AppButton.secondary(
                    text: 'Sign Out',
                    icon: Icons.logout_rounded,
                    onPressed: _handleLogout,
                  ),

                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: AppRadius.roundedSm,
        ),
        child: Icon(icon, color: AppColors.primaryLight, size: 20),
      ),
      title: Text(title, style: AppTypography.titleMedium),
      subtitle: Text(subtitle, style: AppTypography.caption),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
      onTap: onTap,
    );
  }
}
