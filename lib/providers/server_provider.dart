import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/server_model.dart';
import '../models/channel_model.dart';
import '../services/server_service.dart';
import '../services/cache_service.dart';

class ServerProvider extends ChangeNotifier {
  List<ServerModel> _servers = [];
  ServerDetail? _currentServerDetail;
  List<ChannelModel> _channels = [];
  List<ServerInvitation> _invitations = [];
  bool _isLoading = false;
  String? _error;

  List<ServerModel> get servers => _servers;
  ServerDetail? get currentServerDetail => _currentServerDetail;
  List<ChannelModel> get channels => _channels;
  List<ServerInvitation> get invitations => _invitations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Cache keys
  static const String _serversListKey = 'servers_list';
  static String _serverDetailKey(int id) => 'server_${id}_detail';
  static String _channelsKey(int id) => 'server_${id}_channels';

  // Cache TTLs
  static const Duration _serversListTtl = Duration(minutes: 5);
  static const Duration _serverDetailTtl = Duration(minutes: 2);
  static const Duration _channelsTtl = Duration(minutes: 2);

  /// Fetch all servers — serves cached data instantly, refreshes in background.
  Future<void> fetchServers() async {
    // Show cached data immediately (no loading spinner)
    final cached = CacheService.get<List<ServerModel>>(_serversListKey);
    if (cached != null) {
      _servers = cached;
      _error = null;
      notifyListeners();

      // Background refresh
      _backgroundFetchServers();
      return;
    }

    // No cache — show loading
    _isLoading = true;
    notifyListeners();

    try {
      _servers = await ServerService.getMyServers();
      CacheService.put(_serversListKey, _servers, ttl: _serversListTtl);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Background refresh of server list (non-blocking).
  Future<void> _backgroundFetchServers() async {
    try {
      final fresh = await ServerService.getMyServers();
      _servers = fresh;
      CacheService.put(_serversListKey, _servers, ttl: _serversListTtl);
      _error = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Background server fetch failed: $e');
    }
  }

  /// Fetch server details — serves cached data, refreshes in background.
  Future<void> fetchServerDetails(int serverId) async {
    final cachedDetail =
        CacheService.get<ServerDetail>(_serverDetailKey(serverId));
    final cachedChannels =
        CacheService.get<List<ChannelModel>>(_channelsKey(serverId));

    if (cachedDetail != null && cachedChannels != null) {
      _currentServerDetail = cachedDetail;
      _channels = cachedChannels;
      _error = null;
      notifyListeners();

      // Background refresh
      _backgroundFetchServerDetails(serverId);
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _currentServerDetail = await ServerService.getServerDetails(serverId);
      _channels = await ServerService.getChannels(serverId);
      CacheService.put(_serverDetailKey(serverId), _currentServerDetail!,
          ttl: _serverDetailTtl);
      CacheService.put(_channelsKey(serverId), _channels, ttl: _channelsTtl);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Background refresh of server details (non-blocking).
  Future<void> _backgroundFetchServerDetails(int serverId) async {
    try {
      final freshDetail = await ServerService.getServerDetails(serverId);
      final freshChannels = await ServerService.getChannels(serverId);
      _currentServerDetail = freshDetail;
      _channels = freshChannels;
      CacheService.put(_serverDetailKey(serverId), freshDetail,
          ttl: _serverDetailTtl);
      CacheService.put(_channelsKey(serverId), freshChannels,
          ttl: _channelsTtl);
      _error = null;
      notifyListeners();
    } catch (e) {
      debugPrint('Background server detail fetch failed: $e');
    }
  }

  // Create a server
  Future<bool> createServer(String name,
      {String? description, bool isPrivate = false}) async {
    _isLoading = true;
    notifyListeners();

    try {
      await ServerService.createServer(
          name: name, description: description, isPrivate: isPrivate);
      _error = null;

      // Invalidate server list cache to force fresh fetch
      await CacheService.invalidate(_serversListKey);

      // Refresh the server list
      try {
        await fetchServers();
      } catch (fetchError) {
        // If fetch fails, we still created the server successfully
        _error = 'Server created but failed to refresh list: $fetchError';
        debugPrint('Error fetching servers after creation: $fetchError');
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      debugPrint('Error creating server: $e');
      return false;
    }
  }

  // Create a channel
  Future<bool> createChannel(int serverId, String name,
      {String? description}) async {
    try {
      await ServerService.createChannel(
          serverId: serverId, name: name, description: description);
      _channels = await ServerService.getChannels(serverId);
      CacheService.put(_channelsKey(serverId), _channels, ttl: _channelsTtl);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Fetch invitations
  Future<void> fetchInvitations() async {
    try {
      _invitations = await ServerService.getInvitations();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  // Respond to invitation
  Future<bool> respondToInvitation(int invitationId, String action) async {
    try {
      await ServerService.respondToInvitation(invitationId, action);
      await CacheService.invalidate(_serversListKey);
      await fetchInvitations();
      await fetchServers();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Invite user
  Future<bool> inviteUser(int serverId, int userId) async {
    try {
      await ServerService.inviteUser(serverId: serverId, userId: userId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Leave server
  Future<bool> leaveServer(int serverId) async {
    try {
      await ServerService.leaveServer(serverId);
      await CacheService.invalidate(_serversListKey);
      await CacheService.invalidatePrefix('server_${serverId}_');
      await fetchServers();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Delete server
  Future<bool> deleteServer(int serverId) async {
    try {
      await ServerService.deleteServer(serverId);
      await CacheService.invalidate(_serversListKey);
      await CacheService.invalidatePrefix('server_${serverId}_');
      await fetchServers();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Send reminders
  Future<bool> sendReminders(int serverId) async {
    try {
      await ServerService.sendReminders(serverId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<Map<String, dynamic>?> getReminderSettings(int serverId) async {
    try {
      return await ServerService.getReminderSettings(serverId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> updateReminderSettings({
    required int serverId,
    required bool reminderEnabled,
    required int reminderIntervalDays,
  }) async {
    try {
      await ServerService.updateReminderSettings(
        serverId: serverId,
        reminderEnabled: reminderEnabled,
        reminderIntervalDays: reminderIntervalDays,
      );
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
