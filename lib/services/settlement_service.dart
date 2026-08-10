import '../models/settlement_model.dart';
import '../models/paginated_response.dart';
import '../utils/json_parsers.dart';
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

  // Get pending settlements (where user is receiver) — paginated
  static Future<PaginatedResponse<SettlementModel>> getPendingSettlements({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await ApiClient.get(
      '/settlements/pending?page=$page&limit=$limit',
    );
    return PaginatedResponse.fromJson(
      response['data'],
      itemsKey: 'settlements',
      fromJson: (json) => SettlementModel.fromJson(json),
    );
  }

  // Get outgoing settlements (where user is payer) — paginated
  static Future<PaginatedResponse<SettlementModel>> getOutgoingSettlements({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await ApiClient.get(
      '/settlements/outgoing?page=$page&limit=$limit',
    );
    return PaginatedResponse.fromJson(
      response['data'],
      itemsKey: 'settlements',
      fromJson: (json) => SettlementModel.fromJson(json),
    );
  }

  // Get settlements for a server — paginated
  static Future<PaginatedResponse<SettlementModel>> getServerSettlements(
    int serverId, {
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    String endpoint = '/settlements/server/$serverId?page=$page&limit=$limit';
    if (status != null) endpoint += '&status=$status';
    final response = await ApiClient.get(endpoint);
    return PaginatedResponse.fromJson(
      response['data'],
      itemsKey: 'settlements',
      fromJson: (json) => SettlementModel.fromJson(json),
    );
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
  static Future<Map<String, dynamic>> getSettlementHistory(int serverId) async {
    final response =
        await ApiClient.get('/settlements/server/$serverId/history');
    final data = response['data'];
    final settlements = (data['settlements'] as List<dynamic>)
        .map((s) => SettlementModel.fromJson(s))
        .toList();
    return {
      'settlements': settlements,
      'totalSettled': parseDoubleValue(data['totalSettled']),
      'count': parseIntValue(data['count']),
    };
  }
}
