import '../utils/json_parsers.dart';

class ExpenseParticipant {
  final int userId;
  final String username;
  final String? fullName;
  final double amountPaid;
  final double amountOwed;

  ExpenseParticipant({
    required this.userId,
    required this.username,
    this.fullName,
    required this.amountPaid,
    required this.amountOwed,
  });

  factory ExpenseParticipant.fromJson(Map<String, dynamic> json) {
    return ExpenseParticipant(
      userId: parseIntValue(json['userId']),
      username: json['username'] ?? '',
      fullName: json['fullName'],
      amountPaid: parseDoubleValue(json['amountPaid']),
      amountOwed: parseDoubleValue(json['amountOwed']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'amountPaid': amountPaid,
      'amountOwed': amountOwed,
    };
  }
}

class ExpenseModel {
  final int id;
  final String title;
  final String? description;
  final double totalAmount;
  final DateTime expenseDate;
  final Map<String, dynamic>? channel;
  final Map<String, dynamic>? createdBy;
  final List<ExpenseParticipant> participants;
  final DateTime? createdAt;

  ExpenseModel({
    required this.id,
    required this.title,
    this.description,
    required this.totalAmount,
    required this.expenseDate,
    this.channel,
    this.createdBy,
    required this.participants,
    this.createdAt,
  });

  String get createdByUsername =>
      createdBy?['username'] ?? 'Unknown';

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: parseIntValue(json['id']),
      title: json['title'] ?? '',
      description: json['description'],
      totalAmount: parseDoubleValue(json['totalAmount']),
      expenseDate: DateTime.parse(
          json['expenseDate'] ?? DateTime.now().toIso8601String()),
      channel: json['channel'],
      createdBy: json['createdBy'],
      participants: (json['participants'] as List<dynamic>? ?? [])
          .map((p) => ExpenseParticipant.fromJson(p))
          .toList(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }
}
