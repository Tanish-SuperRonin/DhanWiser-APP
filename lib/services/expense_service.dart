import '../models/expense_model.dart';
import '../models/balance_model.dart';
import '../models/paginated_response.dart';
import 'api_client.dart';

class ExpenseService {
  // Add a new expense
  static Future<Map<String, dynamic>> addExpense({
    required int channelId,
    required String title,
    String? description,
    required double totalAmount,
    required String expenseDate,
    required List<Map<String, dynamic>> participants,
  }) async {
    return await ApiClient.post('/expenses', body: {
      'channelId': channelId,
      'title': title,
      if (description != null) 'description': description,
      'totalAmount': totalAmount,
      'expenseDate': expenseDate,
      'participants': participants,
    });
  }

  // Get expenses for a channel (paginated)
  static Future<PaginatedResponse<ExpenseModel>> getChannelExpenses(
    int channelId, {
    int page = 1,
    int limit = 20,
  }) async {
    final response = await ApiClient.get(
      '/expenses/channel/$channelId?page=$page&limit=$limit',
    );
    return PaginatedResponse.fromJson(
      response['data'],
      itemsKey: 'expenses',
      fromJson: (json) => ExpenseModel.fromJson(json),
    );
  }

  // Get all expenses for a server (paginated)
  static Future<PaginatedResponse<ExpenseModel>> getServerExpenses(
    int serverId, {
    int page = 1,
    int limit = 20,
  }) async {
    final response = await ApiClient.get(
      '/expenses/server/$serverId?page=$page&limit=$limit',
    );
    return PaginatedResponse.fromJson(
      response['data'],
      itemsKey: 'expenses',
      fromJson: (json) => ExpenseModel.fromJson(json),
    );
  }

  // Get server balances (not paginated — always returns all members)
  static Future<Map<String, dynamic>> getServerBalances(int serverId) async {
    final response = await ApiClient.get('/expenses/server/$serverId/balances');
    final data = response['data'];

    final balances = (data['balances'] as List<dynamic>)
        .map((b) => BalanceModel.fromJson(b))
        .toList();

    final suggestions = (data['suggestedSettlements'] as List<dynamic>)
        .map((s) => SuggestedSettlement.fromJson(s))
        .toList();

    return {
      'balances': balances,
      'suggestedSettlements': suggestions,
    };
  }

  // Delete an expense
  static Future<void> deleteExpense(int expenseId) async {
    await ApiClient.delete('/expenses/$expenseId');
  }
}
