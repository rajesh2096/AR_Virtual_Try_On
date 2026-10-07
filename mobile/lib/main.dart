import 'package:flutter/material.dart';
import 'core/constants/app_constants.dart';
import 'screens/auth/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const VirtualTryOnApp());
}

class VirtualTryOnApp extends StatelessWidget {
  const VirtualTryOnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Virtual Try-On',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        primaryColor: AppColors.primary,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
          error: AppColors.error,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
