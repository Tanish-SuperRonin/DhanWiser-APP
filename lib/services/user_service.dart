import '../models/user_model.dart';
import 'api_client.dart';

class UserService {
  // Search users globally by username
  static Future<List<PublicUser>> searchUsers(String query) async {
    final response = await ApiClient.get('/users/search?query=$query');
    final users = response['data']['users'] as List<dynamic>;
    return users.map((u) => PublicUser.fromJson(u)).toList();
  }

  // Get user by ID
  static Future<PublicUser> getUserById(int id) async {
    final response = await ApiClient.get('/users/$id');
    return PublicUser.fromJson(response['data']);
  }
}
