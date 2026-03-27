import '../models/settlement_model.dart';
import 'api_client.dart';

class SettlementService {
  // Initiate a settlement
  static Future<Map<String, dynamic>> initiateSettlement({
    required int serverId,
    required int receiverId,
    required double amount,
    String? notes,
    String? proofImage,
  }) async {
    return await ApiClient.post('/settlements', body: {
      'serverId': serverId,
      'receiverId': receiverId,
      'amount': amount,
      if (notes != null) 'notes': notes,
      if (proofImage != null) 'proofImage': proofImage,
    });
  }

  // Get pending settlements (where user is receiver)
  static Future<List<SettlementModel>> getPendingSettlements() async {
    final response = await ApiClient.get('/settlements/pending');
    final settlements = response['data']['settlements'] as List<dynamic>;
    return settlements.map((s) => SettlementModel.fromJson(s)).toList();
  }

  // Get settlements for a server
  static Future<List<SettlementModel>> getServerSettlements(int serverId,
      {String? status}) async {
    String endpoint = '/settlements/server/$serverId';
    if (status != null) endpoint += '?status=$status';
    final response = await ApiClient.get(endpoint);
    final settlements = response['data']['settlements'] as List<dynamic>;
    return settlements.map((s) => SettlementModel.fromJson(s)).toList();
  }

  // Approve a settlement
  static Future<void> approveSettlement(int settlementId) async {
    await ApiClient.post('/settlements/$settlementId/approve');
  }

  // Reject a settlement
  static Future<void> rejectSettlement(int settlementId,
      {String? reason}) async {
    await ApiClient.post('/settlements/$settlementId/reject', body: {
      if (reason != null) 'reason': reason,
    });
  }

  // Get settlement history for a server
  static Future<Map<String, dynamic>> getSettlementHistory(
      int serverId) async {
    final response =
        await ApiClient.get('/settlements/server/$serverId/history');
    final data = response['data'];
    final settlements = (data['settlements'] as List<dynamic>)
        .map((s) => SettlementModel.fromJson(s))
        .toList();
    return {
      'settlements': settlements,
      'totalSettled': (data['totalSettled'] ?? 0).toDouble(),
      'count': data['count'] ?? 0,
    };
  }
}
