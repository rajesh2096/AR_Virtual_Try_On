import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/config/app_config.dart';
import '../../core/constants/app_constants.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import '../home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    _initializeApp();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    // Load custom server URL if saved
    final prefs = await SharedPreferences.getInstance();
    final customUrl = prefs.getString(AppConstants.customServerUrlKey);
    if (customUrl != null && customUrl.isNotEmpty) {
      AppConfig.updateBaseUrl(customUrl);
    }

    // Artificial delay for splash animation
    await Future.delayed(const Duration(milliseconds: 1500));

    final loggedIn = await AuthService.isLoggedIn();

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => loggedIn ? const HomeScreen() : const LoginScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.4),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.checkroom_rounded,
                  size: 56,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'AI Virtual Try-On',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Cross-Platform Dress Simulator',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 48),
              const CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryLight),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
