import 'package:flutter/material.dart';
import 'dart:async';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/api_client.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize — check if user has valid token
  Future<void> initialize() async {
    try {
      final hasToken = await AuthService.isLoggedIn();
      if (hasToken) {
        _currentUser = await AuthService.getProfile();
        _isAuthenticated = true;
      }
    } catch (e) {
      // Token expired or invalid
      await ApiClient.clearTokens();
      _isAuthenticated = false;
      _currentUser = null;
    }
    notifyListeners();
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
      _error = 'Connection error. Is the server running?';
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
      _error = 'Connection error. Is the server running?';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    await AuthService.logout();
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
      _error = 'Connection error';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
