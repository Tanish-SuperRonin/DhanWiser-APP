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
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'],
      expenseCount: json['expenseCount'] ?? 0,
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }
}
