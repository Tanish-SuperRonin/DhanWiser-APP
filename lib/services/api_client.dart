import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  static Future<void> _resetStorage() async {
    try {
      await _storage.deleteAll();
    } catch (_) {}
  }

  static Future<http.Response> _sendRequest(
    Future<http.Response> Function() request,
  ) async {
    try {
      return await request().timeout(_timeout);
    } on TimeoutException {
      rethrow;
    } on SocketException {
      throw ApiException(
        statusCode: 0,
        message:
            'Unable to reach the server. Check your internet connection and try again.',
      );
    } on HandshakeException {
      throw ApiException(
        statusCode: 0,
        message: 'Secure connection failed. Please try again.',
      );
    } on http.ClientException catch (e) {
      throw ApiException(
        statusCode: 0,
        message: e.message.isNotEmpty
            ? e.message
            : 'Network request failed. Please try again.',
      );
    }
  }

  // Token management with web & SharedPreferences fallback
  static Future<void> saveTokens(
      String accessToken, String refreshToken) async {
    try {
      await _storage.write(key: _accessTokenKey, value: accessToken);
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
    } catch (_) {}
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_accessTokenKey, accessToken);
      await prefs.setString(_refreshTokenKey, refreshToken);
    } catch (_) {}
  }

  static Future<String?> getAccessToken() async {
    try {
      final token = await _storage.read(key: _accessTokenKey);
      if (token != null && token.isNotEmpty) return token;
    } catch (_) {}
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_accessTokenKey);
    } catch (_) {}
    return null;
  }

  static Future<String?> getRefreshToken() async {
    try {
      final token = await _storage.read(key: _refreshTokenKey);
      if (token != null && token.isNotEmpty) return token;
    } catch (_) {}
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_refreshTokenKey);
    } catch (_) {}
    return null;
  }

  static Future<void> clearTokens() async {
    await _resetStorage();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_accessTokenKey);
      await prefs.remove(_refreshTokenKey);
    } catch (_) {}
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

  // Auto-refresh token on 401 or 403
  static Future<bool> _tryRefreshToken() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null) return false;

    try {
      final response = await _sendRequest(
        () => http.post(
          Uri.parse('$baseUrl/auth/refresh'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'refreshToken': refreshToken}),
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final newAccessToken = data['data']['accessToken'];
          await saveTokens(newAccessToken, refreshToken);
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
    var response = await _sendRequest(
      () => http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      ),
    );

    // Auto-refresh on 401 or 403
    if ((response.statusCode == 401 || response.statusCode == 403) &&
        withAuth) {
      final refreshed = await _tryRefreshToken();
      if (refreshed) {
        final newHeaders = await _headers(withAuth: true);
        response = await _sendRequest(
          () => http.get(
            Uri.parse('$baseUrl$endpoint'),
            headers: newHeaders,
          ),
        );
      }
    }

    return _processResponse(response);
  }

  // POST request
  static Future<Map<String, dynamic>> post(String endpoint,
      {Map<String, dynamic>? body, bool withAuth = true}) async {
    final headers = await _headers(withAuth: withAuth);
    var response = await _sendRequest(
      () => http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      ),
    );

    if ((response.statusCode == 401 || response.statusCode == 403) &&
        withAuth) {
      final refreshed = await _tryRefreshToken();
      if (refreshed) {
        final newHeaders = await _headers(withAuth: true);
        response = await _sendRequest(
          () => http.post(
            Uri.parse('$baseUrl$endpoint'),
            headers: newHeaders,
            body: body != null ? jsonEncode(body) : null,
          ),
        );
      }
    }

    return _processResponse(response);
  }

  // PUT request
  static Future<Map<String, dynamic>> put(String endpoint,
      {Map<String, dynamic>? body, bool withAuth = true}) async {
    final headers = await _headers(withAuth: withAuth);
    var response = await _sendRequest(
      () => http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      ),
    );

    if ((response.statusCode == 401 || response.statusCode == 403) &&
        withAuth) {
      final refreshed = await _tryRefreshToken();
      if (refreshed) {
        final newHeaders = await _headers(withAuth: true);
        response = await _sendRequest(
          () => http.put(
            Uri.parse('$baseUrl$endpoint'),
            headers: newHeaders,
            body: body != null ? jsonEncode(body) : null,
          ),
        );
      }
    }

    return _processResponse(response);
  }

  // DELETE request
  static Future<Map<String, dynamic>> delete(String endpoint,
      {bool withAuth = true}) async {
    final headers = await _headers(withAuth: withAuth);
    var response = await _sendRequest(
      () => http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      ),
    );

    if ((response.statusCode == 401 || response.statusCode == 403) &&
        withAuth) {
      final refreshed = await _tryRefreshToken();
      if (refreshed) {
        final newHeaders = await _headers(withAuth: true);
        response = await _sendRequest(
          () => http.delete(
            Uri.parse('$baseUrl$endpoint'),
            headers: newHeaders,
          ),
        );
      }
    }

    return _processResponse(response);
  }

  // Process response
  static Map<String, dynamic> _processResponse(http.Response response) {
    final dynamic decodedBody;
    try {
      decodedBody = response.body.isNotEmpty
          ? jsonDecode(response.body)
          : <String, dynamic>{};
    } on FormatException {
      throw ApiException(
        statusCode: response.statusCode,
        message: 'Invalid server response. Please try again.',
      );
    }

    final body =
        decodedBody is Map<String, dynamic> ? decodedBody : <String, dynamic>{};

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
