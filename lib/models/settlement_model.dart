class SettlementModel {
  final int id;
  final int? serverId;
  final String? serverName;
  final Map<String, dynamic>? payer;
  final Map<String, dynamic>? receiver;
  final double amount;
  final String status; // pending, approved, rejected
  final String? notes;
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
    this.initiatedAt,
    this.approvedAt,
  });

  String get payerUsername => payer?['username'] ?? 'Unknown';
  String get payerFullName => payer?['fullName'] ?? 'Unknown';
  String get receiverUsername => receiver?['username'] ?? 'Unknown';
  String get receiverFullName => receiver?['fullName'] ?? 'Unknown';

  factory SettlementModel.fromJson(Map<String, dynamic> json) {
    return SettlementModel(
      id: json['id'],
      serverId: json['serverId'],
      serverName: json['serverName'],
      payer: json['payer'],
      receiver: json['receiver'],
      amount: (json['amount'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      notes: json['notes'],
      initiatedAt: json['initiatedAt'] != null
          ? DateTime.parse(json['initiatedAt'])
          : null,
      approvedAt: json['approvedAt'] != null
          ? DateTime.parse(json['approvedAt'])
          : null,
    );
  }
}
