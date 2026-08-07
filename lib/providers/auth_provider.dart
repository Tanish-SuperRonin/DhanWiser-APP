import 'package:flutter/material.dart';
import 'dart:async';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/api_client.dart';
import '../services/cache_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Initialize — loads cached profile instantly, then validates in background.
  ///
  /// Flow:
  /// 1. Check for stored token
  /// 2. If token exists, load cached profile → mark authenticated immediately
  /// 3. Background: validate token by fetching fresh profile from server
  /// 4. If background validation fails, force re-login
  Future<void> initialize() async {
    try {
      final hasToken = await AuthService.isLoggedIn();
      if (!hasToken) {
        _isAuthenticated = false;
        _currentUser = null;
        notifyListeners();
        return;
      }

      // Step 1: Load cached profile for instant startup
      final cachedUser = await AuthService.getCachedProfile();
      if (cachedUser != null) {
        _currentUser = cachedUser;
        _isAuthenticated = true;
        notifyListeners();

        // Step 2: Validate token in background (non-blocking)
        _backgroundValidate();
        return;
      }

      // No cached profile — must fetch from network
      _currentUser = await AuthService.getProfile();
      _isAuthenticated = true;
    } catch (e) {
      // Token expired or invalid
      await ApiClient.clearTokens();
      await AuthService.clearCachedProfile();
      _isAuthenticated = false;
      _currentUser = null;
    }
    notifyListeners();
  }

  /// Background token validation. Fetches fresh profile to confirm token is still valid.
  /// If it fails, clears auth state (user will see login on next navigation).
  Future<void> _backgroundValidate() async {
    try {
      final freshUser = await AuthService.getProfile();
      _currentUser = freshUser;
      // Profile is already cached inside getProfile()
      notifyListeners();
    } catch (e) {
      debugPrint('Background token validation failed: $e');
      // Token is invalid — force logout
      await ApiClient.clearTokens();
      await AuthService.clearCachedProfile();
      _isAuthenticated = false;
      _currentUser = null;
      notifyListeners();
    }
  }

  // Signup
  Future<bool> signup({
    required String username,
    required String email,
    required String password,
    required String fullName,
    String? upiId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await AuthService.signup(
        username: username,
        email: email,
        password: password,
        fullName: fullName,
        upiId: upiId,
      );

      _currentUser = UserModel.fromJson(response['data']['user']);
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } on TimeoutException {
      _error = 'Request timed out. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('Signup unexpected error: $e');
      _error = 'Unexpected error. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Login
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await AuthService.login(
        email: email,
        password: password,
      );

      _currentUser = UserModel.fromJson(response['data']['user']);
      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      _isLoading = false;
      notifyListeners();
      return false;
    } on TimeoutException {
      _error = 'Request timed out. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('Login unexpected error: $e');
      _error = 'Unexpected error. Please try again.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout — clears everything: tokens, cached profile, app cache
  Future<void> logout() async {
    await AuthService.logout();
    await CacheService.clearAll();
    _currentUser = null;
    _isAuthenticated = false;
    _error = null;
    notifyListeners();
  }

  // Update profile
  Future<bool> updateProfile({
    String? fullName,
    String? upiId,
  }) async {
    try {
      _currentUser = await AuthService.updateProfile(
        fullName: fullName,
        upiId: upiId,
      );
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('Update profile unexpected error: $e');
      _error = 'Unexpected error. Please try again.';
      notifyListeners();
      return false;
    }
  }

  // Guest login for testing (no server needed)
  void loginAsGuest() {
    _currentUser = UserModel(
      id: 0,
      username: 'guest_user',
      email: 'guest@dhanwiser.app',
      fullName: 'Guest User',
      upiId: 'guest@upi',
      createdAt: DateTime.now(),
    );
    _isAuthenticated = true;
    _error = null;
    notifyListeners();
  }

  bool get isGuest => _currentUser?.id == 0;

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
