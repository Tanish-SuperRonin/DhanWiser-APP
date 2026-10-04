import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<void> initialize() async {
    // Handle cold start deep link
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        await _handleUri(initialUri);
      }
    } catch (e) {
      debugPrint('Error handling initial deep link: $e');
    }

    // Handle deep links while app is running
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleUri(uri);
    }, onError: (err) {
      debugPrint('Error in deep link stream: $err');
    });
  }

  Future<void> _handleUri(Uri uri) async {
    if (uri.pathSegments.isEmpty) return;

    if (uri.pathSegments.first == 'join' && uri.pathSegments.length > 1) {
      final serverId = uri.pathSegments[1];
      
      final prefs = await SharedPreferences.getInstance();
      
      final context = navigatorKey.currentContext;
      if (context == null) {
        // App isn't fully ready, store it for later
        await prefs.setString('pending_join_id', serverId);
        return;
      }

      final authProv = Provider.of<AuthProvider>(context, listen: false);
      if (authProv.isAuthenticated) {
        // Already authenticated, navigate immediately
        navigatorKey.currentState?.pushNamed('/join', arguments: {'serverId': int.tryParse(serverId) ?? 0});
      } else {
        // Store for after login
        await prefs.setString('pending_join_id', serverId);
      }
    }
  }

  void dispose() {
    _linkSubscription?.cancel();
  }

  /// Called after successful login to check for pending actions
  static Future<void> checkPendingActions(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final pendingJoinId = prefs.getString('pending_join_id');
    
    if (pendingJoinId != null) {
      await prefs.remove('pending_join_id');
      final serverId = int.tryParse(pendingJoinId);
      if (serverId != null && serverId != 0) {
        // Delay slightly to let the current navigation settle
        Future.delayed(const Duration(milliseconds: 300), () {
          if (context.mounted) {
            Navigator.pushNamed(context, '/join', arguments: {'serverId': serverId});
          }
        });
      }
    }
  }
}
