import '../utils/json_parsers.dart';

class UserModel {
  final int id;
  final String username;
  final String email;
  final String fullName;
  final String? upiId;
  final String? profilePicture;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    this.upiId,
    this.profilePicture,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: parseIntValue(json['id']),
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',
      upiId: json['upiId'],
      profilePicture: json['profilePicture'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'fullName': fullName,
      'upiId': upiId,
      'profilePicture': profilePicture,
    };
  }
}

class PublicUser {
  final int id;
  final String username;
  final String fullName;
  final String? profilePicture;

  PublicUser({
    required this.id,
    required this.username,
    required this.fullName,
    this.profilePicture,
  });

  factory PublicUser.fromJson(Map<String, dynamic> json) {
    return PublicUser(
      id: parseIntValue(json['id']),
      username: json['username'] ?? '',
      fullName: json['fullName'] ?? '',
      profilePicture: json['profilePicture'],
    );
  }
}
