import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
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

  static bool _isRecoverableStorageError(Object error) {
    final message = error.toString().toLowerCase();
    return message.contains('failed to unwrap key') ||
        message.contains('invalidkeyexception') ||
        message.contains('keystore') ||
        message.contains('key permanently invalidated');
  }

  static Future<void> _resetStorage() async {
    try {
      await _storage.deleteAll();
    } catch (_) {
      // Best effort reset for broken keystore state.
    }
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
        message: 'Unable to reach the server. Check your internet connection and try again.',
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

  // Token management
  static Future<void> saveTokens(String accessToken, String refreshToken) async {
    try {
      await _storage.write(key: _accessTokenKey, value: accessToken);
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
    } on PlatformException catch (e) {
      if (_isRecoverableStorageError(e)) {
        await _resetStorage();
        await _storage.write(key: _accessTokenKey, value: accessToken);
        await _storage.write(key: _refreshTokenKey, value: refreshToken);
        return;
      }
      throw ApiException(
        statusCode: 0,
        message: 'Secure storage failed. Please clear app data and try again.',
      );
    }
  }

  static Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: _accessTokenKey);
    } on PlatformException catch (e) {
      if (_isRecoverableStorageError(e)) {
        await _resetStorage();
        return null;
      }
      rethrow;
    }
  }

  static Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _refreshTokenKey);
    } on PlatformException catch (e) {
      if (_isRecoverableStorageError(e)) {
        await _resetStorage();
        return null;
      }
      rethrow;
    }
  }

  static Future<void> clearTokens() async {
    await _resetStorage();
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
    var response = await _sendRequest(
      () => http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: headers,
      ),
    );

    // Auto-refresh on 403
    if (response.statusCode == 403 && withAuth) {
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

    if (response.statusCode == 403 && withAuth) {
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

    if (response.statusCode == 403 && withAuth) {
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

    if (response.statusCode == 403 && withAuth) {
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
