// mengimplementasikan model untuk mengelola data rekening nasabah.
// model ini menyimpan dan mengelola informasi detail rekening seperti
// ID rekening, ID pengguna, nomor rekening, jenis rekening, dan saldo.
class Account {
  // menyimpan ID unik untuk mengidentifikasi rekening
  final String id;

  // menyimpan ID pengguna yang memiliki rekening ini
  final String userId;

  // menyimpan nomor rekening yang digunakan untuk transaksi
  final String accountNumber;

  // mendefinisikan jenis atau tipe rekening nasabah
  final String accountType;

  // menyimpan jumlah saldo rekening yang dapat berubah
  double balance;

  // menginisialisasi objek Account baru dengan parameter wajib
  Account({
    required this.id,
    required this.userId,
    required this.accountNumber,
    required this.accountType,
    required this.balance,
  });

  // mengkonversi data JSON menjadi objek Account
  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'],
      userId: json['userId'],
      accountNumber: json['accountNumber'],
      accountType: json['accountType'],
      balance: json['balance'].toDouble(),
    );
  }

  // mengkonversi objek Account menjadi format JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'accountNumber': accountNumber,
      'accountType': accountType,
      'balance': balance,
    };
  }

  // menghasilkan representasi string dari objek Account
  // untuk keperluan debugging dan logging
  @override
  String toString() {
    return 'Account(id: $id, userId: $userId, accountNumber: $accountNumber, accountType: $accountType, balance: $balance)';
  }
}
