class Account {
  final String id;
  final String userId;
  final String accountNumber;
  final String accountType;
  double balance;

  Account({
    required this.id,
    required this.userId,
    required this.accountNumber,
    required this.accountType,
    required this.balance,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'],
      userId: json['userId'],
      accountNumber: json['accountNumber'],
      accountType: json['accountType'],
      balance: json['balance'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'accountNumber': accountNumber,
      'accountType': accountType,
      'balance': balance,
    };
  }
}
