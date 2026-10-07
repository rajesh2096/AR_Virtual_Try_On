import 'package:flutter/material.dart';

class AppColors {
  // Backgrounds & Surfaces (Obsidian Luxury Palette)
  static const Color background = Color(0xFF0A0B10);
  static const Color surface = Color(0xFF141622);
  static const Color surfaceElevated = Color(0xFF1C1F32);
  static const Color cardBg = Color(0xFF181B2B);
  static const Color border = Color(0xFF262A40);
  static const Color borderSubtle = Color(0xFF1F2338);

  // Core Accents
  static const Color primary = Color(0xFF7C5CFC);          // Interactive Violet
  static const Color primaryDark = Color(0xFF5D3FE0);
  static const Color primaryLight = Color(0xFFA28BFF);
  static const Color secondary = Color(0xFFFF7675);        // Coral / Pink
  static const Color accent = Color(0xFFD4AF37);           // Luxury Gold
  static const Color accentTech = Color(0xFF00E5FF);       // Tech Cyan

  // Typography Tokens
  static const Color textPrimary = Color(0xFFF8F9FA);      // Crisp high-contrast white
  static const Color textSecondary = Color(0xFF8E95A5);    // Muted slate gray
  static const Color textMuted = Color(0xFF5E6578);        // Dimmed caption gray
  static const Color textDisabled = Color(0xFF3E4456);

  // Status & Feedback
  static const Color success = Color(0xFF00C896);
  static const Color warning = Color(0xFFFFB800);
  static const Color error = Color(0xFFFF5252);
  static const Color info = Color(0xFF00E5FF);
  static const Color divider = Color(0xFF22263A);

  // Shimmers & Overlays
  static const Color shimmerBase = Color(0xFF181B2B);
  static const Color shimmerHighlight = Color(0xFF22263C);
  static const Color overlayDark = Color(0x990A0B10);
}

class AppConstants {
  static const String appName = 'AI Virtual Try-On';
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String customServerUrlKey = 'custom_server_url';
}
