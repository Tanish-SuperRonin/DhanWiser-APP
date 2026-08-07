import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A cached entry with its data, timestamp, and TTL.
class _CacheEntry {
  final dynamic data;
  final DateTime cachedAt;
  final Duration ttl;

  _CacheEntry({
    required this.data,
    required this.cachedAt,
    required this.ttl,
  });

  bool get isExpired => DateTime.now().difference(cachedAt) > ttl;
}

/// General-purpose cache service with in-memory LRU + optional disk persistence.
///
/// Usage:
/// ```dart
/// // Get with auto-fetch on miss
/// final servers = await CacheService.getOrFetch(
///   key: 'servers_list',
///   ttl: Duration(minutes: 5),
///   fetcher: () => ServerService.getMyServers(),
/// );
///
/// // Invalidate after mutation
/// CacheService.invalidate('servers_list');
/// ```
class CacheService {
  // In-memory cache store
  static final Map<String, _CacheEntry> _memoryCache = {};

  // Maximum number of entries before LRU eviction
  static const int _maxEntries = 100;

  // Disk cache prefix to avoid key collisions in SharedPreferences
  static const String _diskPrefix = 'cache_';

  // ──────────────────────────────────────────────
  // Core API
  // ──────────────────────────────────────────────

  /// Get a value from cache (memory first, then disk).
  /// Returns null if not found or expired.
  static T? get<T>(String key) {
    final entry = _memoryCache[key];
    if (entry != null && !entry.isExpired) {
      return entry.data as T;
    }
    // Expired — clean up
    if (entry != null) {
      _memoryCache.remove(key);
    }
    return null;
  }

  /// Put a value into the in-memory cache.
  static void put(String key, dynamic data, {required Duration ttl}) {
    // LRU eviction if we're at capacity
    if (_memoryCache.length >= _maxEntries && !_memoryCache.containsKey(key)) {
      _evictOldest();
    }

    _memoryCache[key] = _CacheEntry(
      data: data,
      cachedAt: DateTime.now(),
      ttl: ttl,
    );
  }

  /// Get from cache or fetch using the provided function.
  /// Stores the result in cache on successful fetch.
  static Future<T> getOrFetch<T>({
    required String key,
    required Duration ttl,
    required Future<T> Function() fetcher,
    bool persistToDisk = false,
  }) async {
    // 1. Check memory cache
    final cached = get<T>(key);
    if (cached != null) return cached;

    // 2. Check disk cache if persistence is enabled
    if (persistToDisk) {
      final diskData = await _readFromDisk(key);
      if (diskData != null) {
        put(key, diskData, ttl: ttl);
        // Also trigger background refresh
        _backgroundRefresh(key, ttl, fetcher, persistToDisk);
        return diskData as T;
      }
    }

    // 3. Fetch from network
    final data = await fetcher();
    put(key, data, ttl: ttl);

    if (persistToDisk) {
      await _writeToDisk(key, data);
    }

    return data;
  }

  /// Invalidate a specific cache key (both memory and disk).
  static Future<void> invalidate(String key) async {
    _memoryCache.remove(key);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_diskPrefix$key');
    } catch (_) {}
  }

  /// Invalidate all keys starting with a given prefix.
  /// E.g., `invalidatePrefix('server_5_')` clears all cache for server 5.
  static Future<void> invalidatePrefix(String prefix) async {
    _memoryCache.removeWhere((key, _) => key.startsWith(prefix));
    try {
      final prefs = await SharedPreferences.getInstance();
      final keysToRemove = prefs
          .getKeys()
          .where((k) => k.startsWith('$_diskPrefix$prefix'))
          .toList();
      for (final key in keysToRemove) {
        await prefs.remove(key);
      }
    } catch (_) {}
  }

  /// Clear the entire cache.
  static Future<void> clearAll() async {
    _memoryCache.clear();
    try {
      final prefs = await SharedPreferences.getInstance();
      final keysToRemove =
          prefs.getKeys().where((k) => k.startsWith(_diskPrefix)).toList();
      for (final key in keysToRemove) {
        await prefs.remove(key);
      }
    } catch (_) {}
  }

  /// Check if a key exists and is not expired.
  static bool has(String key) {
    final entry = _memoryCache[key];
    return entry != null && !entry.isExpired;
  }

  // ──────────────────────────────────────────────
  // Disk persistence helpers
  // ──────────────────────────────────────────────

  static Future<void> _writeToDisk(String key, dynamic data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final payload = jsonEncode({
        'data': data,
        'cachedAt': DateTime.now().toIso8601String(),
      });
      await prefs.setString('$_diskPrefix$key', payload);
    } catch (e) {
      debugPrint('CacheService: disk write failed for $key: $e');
    }
  }

  static Future<dynamic> _readFromDisk(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('$_diskPrefix$key');
      if (raw == null) return null;

      final payload = jsonDecode(raw) as Map<String, dynamic>;
      final cachedAt = DateTime.parse(payload['cachedAt'] as String);

      // Disk cache is valid for 24 hours max (stale-while-revalidate)
      if (DateTime.now().difference(cachedAt) > const Duration(hours: 24)) {
        await prefs.remove('$_diskPrefix$key');
        return null;
      }

      return payload['data'];
    } catch (e) {
      debugPrint('CacheService: disk read failed for $key: $e');
      return null;
    }
  }

  // ──────────────────────────────────────────────
  // Internal helpers
  // ──────────────────────────────────────────────

  /// Evict the oldest (first inserted) entry. Simple FIFO for now.
  static void _evictOldest() {
    if (_memoryCache.isEmpty) return;

    String? oldestKey;
    DateTime? oldestTime;

    for (final entry in _memoryCache.entries) {
      if (oldestTime == null || entry.value.cachedAt.isBefore(oldestTime)) {
        oldestKey = entry.key;
        oldestTime = entry.value.cachedAt;
      }
    }

    if (oldestKey != null) {
      _memoryCache.remove(oldestKey);
    }
  }

  /// Background refresh: fetches fresh data and updates cache without blocking.
  static Future<void> _backgroundRefresh<T>(
    String key,
    Duration ttl,
    Future<T> Function() fetcher,
    bool persistToDisk,
  ) async {
    try {
      final data = await fetcher();
      put(key, data, ttl: ttl);
      if (persistToDisk) {
        await _writeToDisk(key, data);
      }
    } catch (e) {
      debugPrint('CacheService: background refresh failed for $key: $e');
    }
  }
}
