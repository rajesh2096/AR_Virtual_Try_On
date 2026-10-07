import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/config/app_config.dart';
import '../../core/constants/app_constants.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = await AuthService.getCurrentUser();
    if (mounted) {
      setState(() {
        _user = user;
        _isLoading = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    await AuthService.logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  void _showServerSettings() {
    final serverController = TextEditingController(text: AppConfig.baseUrl);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Backend Server URL',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Configures where this app connects for API & Uploads.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: serverController,
              label: 'Server URL',
              hint: 'http://10.0.2.2:8000',
              prefixIcon: Icons.dns_rounded,
            ),
            const SizedBox(height: 20),
            CustomButton(
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Account Profile', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppColors.primaryLight)))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        _user?.name.isNotEmpty == true ? _user!.name[0].toUpperCase() : 'U',
                        style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _user?.name ?? 'User',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _user?.email ?? '',
                    style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 32),
                  _buildProfileTile(
                    icon: Icons.dns_rounded,
                    title: 'Server Configuration',
                    subtitle: AppConfig.baseUrl,
                    onTap: _showServerSettings,
                  ),
                  const SizedBox(height: 12),
                  _buildProfileTile(
                    icon: Icons.security_rounded,
                    title: 'Authentication & Security',
                    subtitle: 'JWT Bearer & Password Hashing',
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  _buildProfileTile(
                    icon: Icons.info_outline_rounded,
                    title: 'App Version',
                    subtitle: 'Phase 1.0 (Foundation & Image Pipeline)',
                    onTap: () {},
                  ),
                  const SizedBox(height: 36),
                  CustomButton(
                    text: 'Sign Out',
                    icon: Icons.logout_rounded,
                    color: AppColors.error,
                    onPressed: _handleLogout,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildProfileTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primaryLight, size: 22),
        ),
        title: Text(title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
        onTap: onTap,
      ),
    );
  }
}
