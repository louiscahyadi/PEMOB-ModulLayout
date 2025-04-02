enum TransactionType { deposit, withdrawal, transfer, payment, loan }

enum TransactionStatus { pending, completed, failed, cancelled }

class Transaction {
  final String id;
  final String accountId;
  final TransactionType type;
  final double amount;
  final String description;
  final DateTime timestamp;
  final TransactionStatus status;
  final String? recipientId;
  final String? recipientName;

  Transaction({
    required this.id,
    required this.accountId,
    required this.type,
    required this.amount,
    required this.description,
    required this.timestamp,
    required this.status,
    this.recipientId,
    this.recipientName,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      accountId: json['accountId'],
      type: TransactionType.values.byName(json['type']),
      amount: json['amount'].toDouble(),
      description: json['description'],
      timestamp: DateTime.parse(json['timestamp']),
      status: TransactionStatus.values.byName(json['status']),
      recipientId: json['recipientId'],
      recipientName: json['recipientName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accountId': accountId,
      'type': type.name,
      'amount': amount,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'status': status.name,
      'recipientId': recipientId,
      'recipientName': recipientName,
    };
  }
}
