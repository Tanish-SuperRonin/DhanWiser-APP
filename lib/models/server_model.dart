import '../utils/json_parsers.dart';

class ServerModel {
  final int id;
  final String name;
  final String? description;
  final int? createdBy;
  final String? creatorUsername;
  final bool isLocked;
  final String role;
  final int memberCount;
  final DateTime? joinedAt;
  final DateTime? createdAt;

  ServerModel({
    required this.id,
    required this.name,
    this.description,
    this.createdBy,
    this.creatorUsername,
    this.isLocked = false,
    this.role = 'member',
    this.memberCount = 0,
    this.joinedAt,
    this.createdAt,
  });

  factory ServerModel.fromJson(Map<String, dynamic> json) {
    return ServerModel(
      id: parseIntValue(json['id']),
      name: json['name'] ?? '',
      description: json['description'],
      createdBy: parseNullableIntValue(json['createdBy']),
      creatorUsername: json['creatorUsername'],
      isLocked: parseBoolValue(json['isLocked']),
      role: json['role'] ?? 'member',
      memberCount: parseIntValue(json['memberCount']),
      joinedAt:
          json['joinedAt'] != null ? DateTime.parse(json['joinedAt']) : null,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }
}

class ServerMember {
  final int userId;
  final String username;
  final String fullName;
  final String? profilePicture;
  final String? upiId;
  final String role;
  final DateTime? joinedAt;

  ServerMember({
    required this.userId,
    required this.username,
    required this.fullName,
    this.profilePicture,
    this.upiId,
    this.role = 'member',
    this.joinedAt,
  });

  factory ServerMember.fromJson(Map<String, dynamic> json) {
    return ServerMember(
      userId: parseIntValue(json['userId']),
      username: json['username'] ?? '',
      fullName: json['fullName'] ?? '',
      profilePicture: json['profilePicture'],
      upiId: json['upiId'],
      role: json['role'] ?? 'member',
      joinedAt:
          json['joinedAt'] != null ? DateTime.parse(json['joinedAt']) : null,
    );
  }
}

class ServerDetail {
  final ServerModel server;
  final List<ServerMember> members;
  final String yourRole;

  ServerDetail({
    required this.server,
    required this.members,
    required this.yourRole,
  });

  factory ServerDetail.fromJson(Map<String, dynamic> json) {
    final serverJson = json['server'] as Map<String, dynamic>;
    return ServerDetail(
      server: ServerModel(
        id: parseIntValue(serverJson['id']),
        name: serverJson['name'] ?? '',
        description: serverJson['description'],
        createdBy: parseNullableIntValue(serverJson['createdBy']),
        creatorUsername: serverJson['creatorUsername'],
        isLocked: parseBoolValue(serverJson['isLocked']),
      ),
      members: (json['members'] as List<dynamic>)
          .map((m) => ServerMember.fromJson(m))
          .toList(),
      yourRole: json['yourRole'] ?? 'member',
    );
  }
}

class ServerInvitation {
  final int id;
  final int serverId;
  final String serverName;
  final String? serverDescription;
  final String inviterUsername;
  final String? inviterName;
  final String status;
  final DateTime? createdAt;

  ServerInvitation({
    required this.id,
    required this.serverId,
    required this.serverName,
    this.serverDescription,
    required this.inviterUsername,
    this.inviterName,
    this.status = 'pending',
    this.createdAt,
  });

  factory ServerInvitation.fromJson(Map<String, dynamic> json) {
    return ServerInvitation(
      id: parseIntValue(json['id']),
      serverId: parseIntValue(json['serverId']),
      serverName: json['serverName'] ?? '',
      serverDescription: json['serverDescription'],
      inviterUsername: json['inviterUsername'] ?? '',
      inviterName: json['inviterName'],
      status: json['status'] ?? 'pending',
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }
}
