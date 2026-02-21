import '../models/expense_model.dart';
import '../models/balance_model.dart';
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

  // Get expenses for a channel
  static Future<List<ExpenseModel>> getChannelExpenses(int channelId) async {
    final response = await ApiClient.get('/expenses/channel/$channelId');
    final expenses = response['data']['expenses'] as List<dynamic>;
    return expenses.map((e) => ExpenseModel.fromJson(e)).toList();
  }

  // Get all expenses for a server
  static Future<List<ExpenseModel>> getServerExpenses(int serverId) async {
    final response = await ApiClient.get('/expenses/server/$serverId');
    final expenses = response['data']['expenses'] as List<dynamic>;
    return expenses.map((e) => ExpenseModel.fromJson(e)).toList();
  }

  // Get server balances
  static Future<Map<String, dynamic>> getServerBalances(int serverId) async {
    final response =
        await ApiClient.get('/expenses/server/$serverId/balances');
    final data = response['data'];

    final balances = (data['balances'] as List<dynamic>)
        .map((b) => BalanceModel.fromJson(b))
        .toList();

    final suggestions =
        (data['suggestedSettlements'] as List<dynamic>)
            .map((s) => SuggestedSettlement.fromJson(s))
            .toList();

    return {
      'balances': balances,
      'suggestedSettlements': suggestions,
    };
  }
}
