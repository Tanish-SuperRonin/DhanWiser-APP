import '../utils/json_parsers.dart';

class SettlementModel {
  final int id;
  final int? serverId;
  final String? serverName;
  final Map<String, dynamic>? payer;
  final Map<String, dynamic>? receiver;
  final double amount;
  final String status; // pending, approved, rejected
  final String? notes;
  final String? proofImage;
  final DateTime? initiatedAt;
  final DateTime? approvedAt;

  SettlementModel({
    required this.id,
    this.serverId,
    this.serverName,
    this.payer,
    this.receiver,
    required this.amount,
    this.status = 'pending',
    this.notes,
    this.proofImage,
    this.initiatedAt,
    this.approvedAt,
  });

  String get payerUsername => payer?['username'] ?? 'Unknown';
  String get payerFullName => payer?['fullName'] ?? 'Unknown';
  String get receiverUsername => receiver?['username'] ?? 'Unknown';
  String get receiverFullName => receiver?['fullName'] ?? 'Unknown';
  int? get receiverId =>
      parseNullableIntValue(receiver?['id'] ?? receiver?['userId']);
  int? get payerId =>
      parseNullableIntValue(payer?['id'] ?? payer?['userId']);


  factory SettlementModel.fromJson(Map<String, dynamic> json) {
    return SettlementModel(
      id: parseIntValue(json['id']),
      serverId: parseNullableIntValue(json['serverId']),
      serverName: json['serverName'],
      payer: json['payer'],
      receiver: json['receiver'],
      amount: parseDoubleValue(json['amount']),
      status: json['status'] ?? 'pending',
      notes: json['notes'],
      proofImage: json['proofImage'],
      initiatedAt: json['initiatedAt'] != null
          ? DateTime.parse(json['initiatedAt'])
          : null,
      approvedAt: json['approvedAt'] != null
          ? DateTime.parse(json['approvedAt'])
          : null,
    );
  }
}
