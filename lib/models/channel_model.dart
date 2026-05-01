import '../utils/json_parsers.dart';

class ChannelModel {
  final int id;
  final String name;
  final String? description;
  final int expenseCount;
  final double totalAmount;
  final DateTime? createdAt;

  ChannelModel({
    required this.id,
    required this.name,
    this.description,
    this.expenseCount = 0,
    this.totalAmount = 0.0,
    this.createdAt,
  });

  factory ChannelModel.fromJson(Map<String, dynamic> json) {
    return ChannelModel(
      id: parseIntValue(json['id']),
      name: json['name'] ?? '',
      description: json['description'],
      expenseCount: parseIntValue(json['expenseCount']),
      totalAmount: parseDoubleValue(json['totalAmount']),
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }
}
