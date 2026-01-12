class PaymentModel {
  final String id;
  final String userId;
  final double amount;
  final String status;
  final String type;
  final DateTime createdAt;

  PaymentModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.status,
    required this.type,
    required this.createdAt,
  });

  factory PaymentModel.fromFirestore(Map<String, dynamic> data, String id) {
    return PaymentModel(
      id: id,
      userId: data['userId'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      status: data['status'] ?? 'pending',
      type: data['type'] ?? 'withdrawal',
      createdAt: data['createdAt'] != null
          ? DateTime.parse(data['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'amount': amount,
      'status': status,
      'type': type,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
