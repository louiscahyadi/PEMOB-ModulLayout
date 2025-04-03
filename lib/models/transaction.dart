// enum untuk jenis-jenis transaksi
enum TransactionType {
  // setoran/deposit
  deposit,

  // penarikan
  withdrawal,

  // transfer
  transfer,

  // pembayaran
  payment,

  // pinjaman
  loan,
}

// enum untuk status transaksi
enum TransactionStatus {
  // transaksi sedang diproses
  pending,

  // transaksi berhasil
  completed,

  // transaksi gagal
  failed,

  // transaksi dibatalkan
  cancelled,
}

// model untuk data transaksi keuangan
// kelas ini menyimpan informasi transaksi seperti id, accountId
// jenis transaksi, jumlah, deskripsi, waktu, status, dan informasi penerima
class Transaction {
  // ID unik transaksi
  final String id;

  // ID rekening yang melakukan transaksi
  final String accountId;

  // jenis transaksi
  final TransactionType type;

  // jumlah transaksi
  final double amount;

  // deskripsi transaksi
  final String description;

  // waktu transaksi
  final DateTime timestamp;

  // status transaksi
  final TransactionStatus status;

  // ID penerima
  final String? recipientId;

  // nama penerima
  final String? recipientName;

  // constructor untuk membuat objek transaction baru
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

  // membuat objek transaction dari JSON
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

  // mengubah objek transaction menjadi JSON
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

  // mengubah objek transaction menjadi string untuk keperluan debugging
  @override
  String toString() {
    return 'Transaction(id: $id, type: ${type.name}, amount: $amount, status: ${status.name})';
  }
}
