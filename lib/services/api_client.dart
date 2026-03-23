import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  // Render free-tier cold starts can take 30-60s
  static const Duration _timeout = Duration(seconds: 90);
  // Render-deployed backend
  static String get baseUrl {
    return 'https://dhanwiser-app.onrender.com/api';
  }

  static const _storage = FlutterSecureStorage();
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  // Token management
  static Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  static Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  static Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  // Build headers with JWT
  static Future<Map<String, String>> _headers({bool withAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (withAuth) {
      final token = await getAccessToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  // Auto-refresh token on 403
  static Future<bool> _tryRefreshToken() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null) return false;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final newAccessToken = data['data']['accessToken'];
          await _storage.write(key: _accessTokenKey, value: newAccessToken);
          return true;
        }
      }
    } catch (_) {}
    return false;
  }

  // GET request
  static Future<Map<String, dynamic>> get(String endpoint,
      {bool withAuth = true}) async {
    final headers = await _headers(withAuth: withAuth);
    var response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    ).timeout(_timeout);

    // Auto-refresh on 403
    if (response.statusCode == 403 && withAuth) {
      final refreshed = await _tryRefreshToken();
      if (refreshed) {
        final newHeaders = await _headers(withAuth: true);
        response = await http.get(
          Uri.parse('$baseUrl$endpoint'),
          headers: newHeaders,
        ).timeout(_timeout);
      }
    }

    return _processResponse(response);
  }

  // POST request
  static Future<Map<String, dynamic>> post(String endpoint,
      {Map<String, dynamic>? body, bool withAuth = true}) async {
    final headers = await _headers(withAuth: withAuth);
    var response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    ).timeout(_timeout);

    if (response.statusCode == 403 && withAuth) {
      final refreshed = await _tryRefreshToken();
      if (refreshed) {
        final newHeaders = await _headers(withAuth: true);
        response = await http.post(
          Uri.parse('$baseUrl$endpoint'),
          headers: newHeaders,
          body: body != null ? jsonEncode(body) : null,
        ).timeout(_timeout);
      }
    }

    return _processResponse(response);
  }

  // PUT request
  static Future<Map<String, dynamic>> put(String endpoint,
      {Map<String, dynamic>? body, bool withAuth = true}) async {
    final headers = await _headers(withAuth: withAuth);
    var response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    ).timeout(_timeout);

    if (response.statusCode == 403 && withAuth) {
      final refreshed = await _tryRefreshToken();
      if (refreshed) {
        final newHeaders = await _headers(withAuth: true);
        response = await http.put(
          Uri.parse('$baseUrl$endpoint'),
          headers: newHeaders,
          body: body != null ? jsonEncode(body) : null,
        ).timeout(_timeout);
      }
    }

    return _processResponse(response);
  }

  // DELETE request
  static Future<Map<String, dynamic>> delete(String endpoint,
      {bool withAuth = true}) async {
    final headers = await _headers(withAuth: withAuth);
    var response = await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    ).timeout(_timeout);

    if (response.statusCode == 403 && withAuth) {
      final refreshed = await _tryRefreshToken();
      if (refreshed) {
        final newHeaders = await _headers(withAuth: true);
        response = await http.delete(
          Uri.parse('$baseUrl$endpoint'),
          headers: newHeaders,
        ).timeout(_timeout);
      }
    }

    return _processResponse(response);
  }

  // Process response
  static Map<String, dynamic> _processResponse(http.Response response) {
    final dynamic decodedBody;
    try {
      decodedBody =
          response.body.isNotEmpty ? jsonDecode(response.body) : <String, dynamic>{};
    } on FormatException {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Invalid server response. Please try again.',
      );
    }

    final body = decodedBody is Map<String, dynamic>
        ? decodedBody
        : <String, dynamic>{};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: body['error'] ?? body['message'] ?? 'Something went wrong',
      );
    }
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException({required this.statusCode, required this.message});

  @override
  String toString() => message;
}
