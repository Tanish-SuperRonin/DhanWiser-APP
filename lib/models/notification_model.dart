import '../utils/json_parsers.dart';

class AppNotification {
  final int id;
  final String type;
  final String title;
  final String message;
  final bool isRead;
  final int? relatedId;
  final DateTime? createdAt;
  final double? amount;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.isRead = false,
    this.relatedId,
    this.createdAt,
    this.amount,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: parseIntValue(json['id']),
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      isRead: parseBoolValue(json['isRead']),
      relatedId: parseNullableIntValue(json['relatedId']),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      amount: json['amount'] != null ? double.tryParse(json['amount'].toString()) : null,
    );
  }
}
