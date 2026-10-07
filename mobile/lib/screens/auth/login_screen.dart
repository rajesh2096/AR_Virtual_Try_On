import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/config/app_config.dart';
import '../../core/constants/app_constants.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../home/home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showServerSettingsModal() {
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
              'Use 10.0.2.2:8000 for Android Emulator, 127.0.0.1:8000 for iOS Simulator, or your PC IP (e.g. http://192.168.1.X:8000) for physical Android devices.',
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
                    content: Text(healthy ? 'Connected to backend successfully!' : 'Server saved, but health check failed at $url'),
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

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await AuthService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_ethernet_rounded, color: AppColors.textSecondary),
            tooltip: 'Configure Backend URL',
            onPressed: _showServerSettingsModal,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.checkroom_rounded, size: 40, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Welcome Back',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sign in to experience AI Virtual Try-On',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 36),
                CustomTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  hint: 'alex@example.com',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Email is required';
                    if (!val.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: '••••••••',
                  obscureText: _obscurePassword,
                  prefixIcon: Icons.lock_outline_rounded,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.textMuted,
                      size: 20,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Password is required';
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                CustomButton(
                  text: 'Sign In',
                  isLoading: _isLoading,
                  onPressed: _handleLogin,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Don't have an account?",
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const RegisterScreen()),
                        );
                      },
                      child: const Text(
                        'Register',
                        style: TextStyle(
                          color: AppColors.primaryLight,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
