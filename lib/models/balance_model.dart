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
      userId: json['userId'],
      username: json['username'] ?? '',
      fullName: json['fullName'] ?? '',
      totalPaid: (json['totalPaid'] ?? 0).toDouble(),
      totalOwed: (json['totalOwed'] ?? 0).toDouble(),
      totalSettled: (json['totalSettled'] ?? 0).toDouble(),
      balance: (json['balance'] ?? 0).toDouble(),
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
      amount: (json['amount'] ?? 0).toDouble(),
    );
  }
}
