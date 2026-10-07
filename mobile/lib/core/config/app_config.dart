import 'dart:io';
import 'package:flutter/foundation.dart';

class AppConfig {
  // Default base URLs depending on runtime environment
  // Android Emulator maps 10.0.2.2 to host machine's 127.0.0.1
  // iOS Simulator / Desktop can access 127.0.0.1 directly
  static String get defaultBaseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000';
    } else {
      return 'http://127.0.0.1:8000';
    }
  }

  static String baseUrl = defaultBaseUrl;

  static String get apiBaseUrl => '$baseUrl/api';

  static void updateBaseUrl(String newUrl) {
    if (newUrl.endsWith('/')) {
      baseUrl = newUrl.substring(0, newUrl.length - 1);
    } else {
      baseUrl = newUrl;
    }
  }
}
