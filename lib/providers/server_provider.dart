import 'package:flutter/material.dart';
import '../models/server_model.dart';
import '../models/channel_model.dart';
import '../services/server_service.dart';

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

  // Fetch all servers for the user
  Future<void> fetchServers() async {
    _isLoading = true;
    notifyListeners();

    try {
      _servers = await ServerService.getMyServers();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Fetch server details
  Future<void> fetchServerDetails(int serverId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentServerDetail = await ServerService.getServerDetails(serverId);
      _channels = await ServerService.getChannels(serverId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Create a server
  Future<bool> createServer(String name, {String? description, bool isPrivate = false}) async {
    _isLoading = true;
    notifyListeners();

    try {
      await ServerService.createServer(name: name, description: description, isPrivate: isPrivate);
      _error = null;

      // Refresh the server list
      try {
        await fetchServers();
      } catch (fetchError) {
        // If fetch fails, we still created the server successfully
        _error = 'Server created but failed to refresh list: $fetchError';
        print('Error fetching servers after creation: $fetchError');
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      print('Error creating server: $e');
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
