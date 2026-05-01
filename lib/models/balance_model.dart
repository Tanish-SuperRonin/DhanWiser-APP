import '../utils/json_parsers.dart';

class BalanceModel {
  final int userId;
  final String username;
  final String fullName;
  final double totalPaid;
  final double totalOwed;
  final double totalSettled;
  final double balance;
  final String status; // gets_back, owes, settled

  BalanceModel({
    required this.userId,
    required this.username,
    required this.fullName,
    required this.totalPaid,
    required this.totalOwed,
    required this.totalSettled,
    required this.balance,
    required this.status,
  });

  factory BalanceModel.fromJson(Map<String, dynamic> json) {
    return BalanceModel(
      userId: parseIntValue(json['userId']),
      username: json['username'] ?? '',
      fullName: json['fullName'] ?? '',
      totalPaid: parseDoubleValue(json['totalPaid']),
      totalOwed: parseDoubleValue(json['totalOwed']),
      totalSettled: parseDoubleValue(json['totalSettled']),
      balance: parseDoubleValue(json['balance']),
      status: json['status'] ?? 'settled',
    );
  }
}

class SuggestedSettlement {
  final Map<String, dynamic> from;
  final Map<String, dynamic> to;
  final double amount;

  SuggestedSettlement({
    required this.from,
    required this.to,
    required this.amount,
  });

  String get fromUsername => from['username'] ?? 'Unknown';
  String get toUsername => to['username'] ?? 'Unknown';

  factory SuggestedSettlement.fromJson(Map<String, dynamic> json) {
    return SuggestedSettlement(
      from: json['from'] ?? {},
      to: json['to'] ?? {},
      amount: parseDoubleValue(json['amount']),
    );
  }
}
