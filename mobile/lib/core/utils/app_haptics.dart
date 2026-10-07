import 'package:flutter/services.dart';

class AppHaptics {
  /// Light click for button taps, tab selection, filter chips
  static void selectionClick() {
    HapticFeedback.selectionClick();
  }

  /// Subtle light impact for card taps, modals
  static void lightImpact() {
    HapticFeedback.lightImpact();
  }

  /// Medium impact for primary actions (e.g. Try-On button, Upload)
  static void mediumImpact() {
    HapticFeedback.mediumImpact();
  }

  /// Heavy impact for state completions / key milestones
  static void heavyImpact() {
    HapticFeedback.heavyImpact();
  }

  /// Success or error vibration sequence
  static void vibrate() {
    HapticFeedback.vibrate();
  }
}
