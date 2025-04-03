// model untuk data rekening nasabah
// unutk menyimpan informasi rekening seperti id, userId
// nomor rekening, jenis rekening, dan saldo
class Account {
  // ID unik rekening
  final String id;

  // ID pengguna pemilik rekening
  final String userId;

  // nomor rekening
  final String accountNumber;

  // jenis rekening
  final String accountType;

  // saldo rekening
  double balance;

  // constructor untuk membuat objek account baru
  Account({
    required this.id,
    required this.userId,
    required this.accountNumber,
    required this.accountType,
    required this.balance,
  });

  // membuat objek account dari JSON
  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'],
      userId: json['userId'],
      accountNumber: json['accountNumber'],
      accountType: json['accountType'],
      balance: json['balance'].toDouble(),
    );
  }

  // mengubah objek account menjadi JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'accountNumber': accountNumber,
      'accountType': accountType,
      'balance': balance,
    };
  }

  // mengubah objek account menjadi string untuk keperluan debugging
  @override
  String toString() {
    return 'Account(id: $id, userId: $userId, accountNumber: $accountNumber, accountType: $accountType, balance: $balance)';
  }
}
