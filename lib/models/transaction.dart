// mendefinisikan jenis-jenis transaksi yang dapat dilakukan
enum TransactionType {
  // menyimpan uang ke dalam rekening
  deposit,

  // mengambil uang dari rekening
  withdrawal,

  // mengirim uang ke rekening lain
  transfer,

  // melakukan pembayaran untuk layanan atau produk
  payment,

  // mengajukan atau mencairkan pinjaman
  loan,
}

// mendefinisikan status-status yang mungkin terjadi pada transaksi
enum TransactionStatus {
  // menandakan transaksi sedang dalam proses
  pending,

  // menandakan transaksi telah berhasil diselesaikan
  completed,

  // menandakan transaksi mengalami kegagalan
  failed,

  // menandakan transaksi telah dibatalkan
  cancelled,
}

// mengimplementasikan model data untuk mencatat transaksi keuangan
// menyimpan detail transaksi seperti id, id rekening, jenis, jumlah
// deskripsi, waktu, status, dan informasi penerima transfer
class Transaction {
  // id unik transaksi
  final String id;

  // id rekening yang melakukan transaksi
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

  // id penerima
  final String? recipientId;

  // nama penerima
  final String? recipientName;

  // konstruktor untuk membuat objek transaksi baru
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

  // membuat objek transaksi dari JSON
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

  // mengubah objek transaksi menjadi JSON
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

  // mengubah objek transaksi menjadi string untuk keperluan debugging
  @override
  String toString() {
    return 'Transaction(id: $id, type: ${type.name}, amount: $amount, status: ${status.name})';
  }
}
