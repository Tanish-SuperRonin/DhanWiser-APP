import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'api_client.dart';

class AuthService {
  static const String _cachedProfileKey = 'cached_user_profile';

  // ──────────────────────────────────────────────
  // Auth endpoints
  // ──────────────────────────────────────────────

  // Signup
  static Future<Map<String, dynamic>> signup({
    required String username,
    required String email,
    required String password,
    required String fullName,
    String? upiId,
  }) async {
    final response = await ApiClient.post(
      '/auth/signup',
      body: {
        'username': username,
        'email': email,
        'password': password,
        'fullName': fullName,
        if (upiId != null && upiId.isNotEmpty) 'upiId': upiId,
      },
      withAuth: false,
    );

    // Save tokens
    final data = response['data'];
    await ApiClient.saveTokens(data['accessToken'], data['refreshToken']);

    // Cache user profile for persistent login
    if (data['user'] != null) {
      final user = UserModel.fromJson(data['user']);
      await cacheUserProfile(user);
    }

    return response;
  }

  // Login
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await ApiClient.post(
      '/auth/login',
      body: {
        'email': email,
        'password': password,
      },
      withAuth: false,
    );

    final data = response['data'];
    await ApiClient.saveTokens(data['accessToken'], data['refreshToken']);

    // Cache user profile for persistent login
    if (data['user'] != null) {
      final user = UserModel.fromJson(data['user']);
      await cacheUserProfile(user);
    }

    return response;
  }

  // Logout
  static Future<void> logout() async {
    final refreshToken = await ApiClient.getRefreshToken();
    try {
      await ApiClient.post(
        '/auth/logout',
        body: {'refreshToken': refreshToken},
        withAuth: false,
      );
    } catch (_) {
      // Ignore logout errors
    }
    await ApiClient.clearTokens();
    await clearCachedProfile();
  }

  // Get current user profile
  static Future<UserModel> getProfile() async {
    final response = await ApiClient.get('/users/profile');
    final user = UserModel.fromJson(response['data']);
    // Update the cached profile with fresh data
    await cacheUserProfile(user);
    return user;
  }

  // Update profile
  static Future<UserModel> updateProfile({
    String? fullName,
    String? upiId,
    String? profilePicture,
  }) async {
    final body = <String, dynamic>{};
    if (fullName != null) body['fullName'] = fullName;
    if (upiId != null) body['upiId'] = upiId;
    if (profilePicture != null) body['profilePicture'] = profilePicture;

    final response = await ApiClient.put('/users/profile', body: body);
    final user = UserModel.fromJson(response['data']);
    // Update cache with the new profile
    await cacheUserProfile(user);
    return user;
  }

  // Check if user is logged in (has valid token)
  static Future<bool> isLoggedIn() async {
    final token = await ApiClient.getAccessToken();
    return token != null;
  }

  // ──────────────────────────────────────────────
  // Cached profile persistence
  // ──────────────────────────────────────────────

  /// Save user profile to disk for instant app startup.
  static Future<void> cacheUserProfile(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = jsonEncode(user.toJson());
      await prefs.setString(_cachedProfileKey, json);
    } catch (_) {
      // Non-critical — don't crash if disk write fails
    }
  }

  /// Load cached user profile from disk.
  /// Returns null if no cached profile exists.
  static Future<UserModel?> getCachedProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cachedProfileKey);
      if (raw == null) return null;

      final json = jsonDecode(raw) as Map<String, dynamic>;
      return UserModel.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  /// Clear cached profile (on logout).
  static Future<void> clearCachedProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cachedProfileKey);
    } catch (_) {}
  }
}
