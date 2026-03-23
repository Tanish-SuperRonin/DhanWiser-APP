import '../models/server_model.dart';
import '../models/channel_model.dart';
import 'api_client.dart';

class ServerService {
  // Create a new server
  static Future<Map<String, dynamic>> createServer({
    required String name,
    String? description,
    bool isPrivate = false,
  }) async {
    return await ApiClient.post('/servers', body: {
      'name': name,
      if (description != null) 'description': description,
      'isLocked': isPrivate,
    });
  }

  // Get all servers the user belongs to
  static Future<List<ServerModel>> getMyServers() async {
    final response = await ApiClient.get('/servers');
    final servers = response['data']['servers'] as List<dynamic>;
    return servers.map((s) => ServerModel.fromJson(s)).toList();
  }

  // Get server details
  static Future<ServerDetail> getServerDetails(int serverId) async {
    final response = await ApiClient.get('/servers/$serverId');
    return ServerDetail.fromJson(response['data']);
  }

  // Invite a user to server
  static Future<Map<String, dynamic>> inviteUser({
    required int serverId,
    required int userId,
  }) async {
    return await ApiClient.post('/servers/invite', body: {
      'serverId': serverId,
      'userId': userId,
    });
  }

  // Get pending invitations
  static Future<List<ServerInvitation>> getInvitations() async {
    final response = await ApiClient.get('/servers/invitations');
    final invitations = response['data']['invitations'] as List<dynamic>;
    return invitations.map((i) => ServerInvitation.fromJson(i)).toList();
  }

  // Respond to invitation (accept/reject)
  static Future<void> respondToInvitation(int invitationId, String action) async {
    await ApiClient.post('/servers/invitations/$invitationId/respond', body: {
      'action': action,
    });
  }

  // Leave a server
  static Future<void> leaveServer(int serverId) async {
    await ApiClient.delete('/servers/$serverId/leave');
  }

  // Delete a server
  static Future<void> deleteServer(int serverId) async {
    await ApiClient.delete('/servers/$serverId');
  }

  // Send reminders
  static Future<Map<String, dynamic>> sendReminders(int serverId) async {
    return await ApiClient.post('/servers/$serverId/reminders/send', body: {});
  }

  // Get channels for a server
  static Future<List<ChannelModel>> getChannels(int serverId) async {
    final response = await ApiClient.get('/channels/server/$serverId');
    final channels = response['data']['channels'] as List<dynamic>;
    return channels.map((c) => ChannelModel.fromJson(c)).toList();
  }

  // Create a channel
  static Future<Map<String, dynamic>> createChannel({
    required int serverId,
    required String name,
    String? description,
  }) async {
    return await ApiClient.post('/channels', body: {
      'serverId': serverId,
      'name': name,
      if (description != null) 'description': description,
    });
  }
}
