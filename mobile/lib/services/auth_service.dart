import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../core/network/api_client.dart';
import '../models/user_model.dart';

class AuthService {
  static Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(AppConstants.userKey);
    if (userJson != null) {
      try {
        return UserModel.fromJson(jsonDecode(userJson));
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.tokenKey);
    return token != null && token.isNotEmpty;
  }

  static Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await ApiClient.post(
      '/auth/register',
      body: {
        'name': name,
        'email': email,
        'password': password,
      },
      requireAuth: false,
    );

    final token = response['access_token'];
    final user = UserModel.fromJson(response['user']);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.tokenKey, token);
    await prefs.setString(AppConstants.userKey, jsonEncode(user.toJson()));

    return user;
  }

  static Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await ApiClient.post(
      '/auth/login',
      body: {
        'email': email,
        'password': password,
      },
      requireAuth: false,
    );

    final token = response['access_token'];
    final user = UserModel.fromJson(response['user']);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.tokenKey, token);
    await prefs.setString(AppConstants.userKey, jsonEncode(user.toJson()));

    return user;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.userKey);
  }

  static Future<bool> checkBackendHealth() async {
    try {
      final response = await ApiClient.get('/health', requireAuth: false);
      return response != null && response['status'] == 'healthy';
    } catch (_) {
      return false;
    }
  }
}
