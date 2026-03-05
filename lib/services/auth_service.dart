import '../models/user_model.dart';
import 'api_client.dart';

class AuthService {
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
  }

  // Get current user profile
  static Future<UserModel> getProfile() async {
    final response = await ApiClient.get('/users/profile');
    return UserModel.fromJson(response['data']);
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
    return UserModel.fromJson(response['data']);
  }

  // Check if user is logged in (has valid token)
  static Future<bool> isLoggedIn() async {
    final token = await ApiClient.getAccessToken();
    return token != null;
  }
}
