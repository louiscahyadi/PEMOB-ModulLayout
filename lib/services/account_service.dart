import 'package:uuid/uuid.dart';
import '../models/account.dart';
import '../models/transaction.dart';
import '../services/auth_service.dart';
import '../utils/logger.dart';

// mengelola layanan rekening dan transaksi nasabah
class AccountService {
  // mengimplementasikan pola singleton
  static final AccountService _instance = AccountService._internal();
  factory AccountService() => _instance;
  AccountService._internal();

  final Uuid _uuid = const Uuid();
  final AuthService _authService = AuthService();

  // menyimpan data rekening sementara
  // akan dimigrasi ke database pada implementasi selanjutnya
  final Map<String, Account> _accounts = {
    'account1': Account(
      id: 'account1',
      userId: 'user1',
      accountNumber: '1234567890',
      accountType: 'Tabungan',
      balance: 1200000,
    ),
  };

  // menyimpan data transaksi sementara
  // akan dimigrasi ke database pada implementasi selanjutnya
  final List<Transaction> _transactions = [
    Transaction(
      id: 'trans1',
      accountId: 'account1',
      type: TransactionType.deposit,
      amount: 500000,
      description: 'Setoran awal',
      timestamp: DateTime.now().subtract(const Duration(days: 30)),
      status: TransactionStatus.completed,
    ),
    Transaction(
      id: 'trans2',
      accountId: 'account1',
      type: TransactionType.deposit,
      amount: 700000,
      description: 'Gaji bulan Mei',
      timestamp: DateTime.now().subtract(const Duration(days: 15)),
      status: TransactionStatus.completed,
    ),
    Transaction(
      id: 'trans3',
      accountId: 'account1',
      type: TransactionType.withdrawal,
      amount: 100000,
      description: 'Penarikan ATM',
      timestamp: DateTime.now().subtract(const Duration(days: 5)),
      status: TransactionStatus.completed,
    ),
    Transaction(
      id: 'trans4',
      accountId: 'account1',
      type: TransactionType.payment,
      amount: 50000,
      description: 'Pembayaran listrik',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      status: TransactionStatus.completed,
    ),
  ];

  // mengambil data rekening pengguna yang sedang aktif
  // mengembalikan objek account jika ditemukan, null jika tidak ada
  Future<Account?> getCurrentUserAccount() async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) {
      Logger.warning(
          'AccountService: Tidak dapat mendapatkan rekening karena pengguna tidak login');
      return null;
    }

    try {
      // mecari rekening berdasarkan userId
      final account = _accounts.values.firstWhere(
        (account) => account.userId == currentUser.id,
        orElse: () {
          // jika rekening tidak ditemukan, buat rekening baru untuk pengguna tersebut
          final newAccountId = 'account_${currentUser.id}';
          final newAccount = Account(
            id: newAccountId,
            userId: currentUser.id,
            accountNumber:
                '${10000000 + int.parse(currentUser.id.replaceAll(RegExp(r'[^0-9]'), ''))}',
            accountType: 'Tabungan',
            balance: 500000, // saldo awal
          );

          // menyimpan rekening baru
          _accounts[newAccountId] = newAccount;

          Logger.info(
              'AccountService: Membuat rekening baru untuk pengguna: ${currentUser.id}');

          // membuat transaksi setoran awal
          final transaction = Transaction(
            id: _uuid.v4(),
            accountId: newAccountId,
            type: TransactionType.deposit,
            amount: 500000,
            description: 'Setoran awal',
            timestamp: DateTime.now(),
            status: TransactionStatus.completed,
          );

          _transactions.add(transaction);

          return newAccount;
        },
      );

      Logger.info(
          'AccountService: Rekening ditemukan untuk pengguna ${currentUser.id}: ${account.id}');
      return account;
    } catch (e) {
      Logger.error('AccountService: Error saat mendapatkan rekening: $e');
      return null;
    }
  }

  // mengambil riwayat transaksi berdasarkan id rekening
  // mengembalikan daftar transaksi dengan jumlah maksimal sesuai parameter limit
  Future<List<Transaction>> getTransactions(String accountId,
      {int limit = 10}) async {
    try {
      final transactions = _transactions
          .where((transaction) => transaction.accountId == accountId)
          .toList();

      // mengurutkan berdasarkan waktu (terbaru)
      transactions.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      // menerapkan limit
      if (transactions.length > limit) {
        return transactions.sublist(0, limit);
      }

      Logger.info(
          'AccountService: Mendapatkan ${transactions.length} transaksi untuk rekening: $accountId');
      return transactions;
    } catch (e) {
      Logger.error('AccountService: Error saat mendapatkan transaksi: $e');
      return [];
    }
  }

  // memproses setoran ke rekening
  // mengembalikan true jika berhasil, false jika gagal
  Future<bool> deposit(
      String accountId, double amount, String description) async {
    try {
      final account = _accounts[accountId];
      if (account == null) {
        Logger.warning(
            'AccountService: Rekening tidak ditemukan untuk deposit: $accountId');
        return false;
      }

      // mengupdate saldo rekening
      account.balance += amount;

      // mmebuat catatan transaksi
      final transaction = Transaction(
        id: _uuid.v4(),
        accountId: accountId,
        type: TransactionType.deposit,
        amount: amount,
        description: description,
        timestamp: DateTime.now(),
        status: TransactionStatus.completed,
      );

      _transactions.add(transaction);

      Logger.info(
          'AccountService: Deposit berhasil untuk rekening $accountId: ${amount.toStringAsFixed(0)}');
      return true;
    } catch (e) {
      Logger.error('AccountService: Error saat melakukan deposit: $e');
      return false;
    }
  }

  // memproses penarikan dari rekening
  // mengembalikan true jika berhasil, false jika gagal
  Future<bool> withdraw(
      String accountId, double amount, String description) async {
    try {
      final account = _accounts[accountId];
      if (account == null) {
        Logger.warning(
            'AccountService: Rekening tidak ditemukan untuk penarikan: $accountId');
        return false;
      }

      // memeriksa apakah saldo mencukupi
      if (account.balance < amount) {
        Logger.warning(
            'AccountService: Saldo tidak mencukupi untuk penarikan: ${account.balance} < $amount');
        return false;
      }

      // mengupdate saldo rekening
      account.balance -= amount;

      // membuat catatan transaksi
      final transaction = Transaction(
        id: _uuid.v4(),
        accountId: accountId,
        type: TransactionType.withdrawal,
        amount: amount,
        description: description,
        timestamp: DateTime.now(),
        status: TransactionStatus.completed,
      );

      _transactions.add(transaction);

      Logger.info(
          'AccountService: Penarikan berhasil dari rekening $accountId: ${amount.toStringAsFixed(0)}');
      return true;
    } catch (e) {
      Logger.error('AccountService: Error saat melakukan penarikan: $e');
      return false;
    }
  }

  // memproses transfer antar rekening
  // mengembalikan true jika berhasil, false jika gagal
  Future<bool> transfer(String fromAccountId, String toAccountId,
      String recipientName, double amount, String description) async {
    try {
      final fromAccount = _accounts[fromAccountId];
      final toAccount = _accounts[toAccountId];

      if (fromAccount == null || toAccount == null) {
        Logger.warning(
            'AccountService: Rekening tidak ditemukan untuk transfer: from=$fromAccountId, to=$toAccountId');
        return false;
      }

      // memeriksa apakah saldo mencukupi
      if (fromAccount.balance < amount) {
        Logger.warning(
            'AccountService: Saldo tidak mencukupi untuk transfer: ${fromAccount.balance} < $amount');
        return false;
      }

      // mengupdate saldo rekening
      fromAccount.balance -= amount;
      toAccount.balance += amount;

      // membuat catatan transaksi
      final outgoingTransaction = Transaction(
        id: _uuid.v4(),
        accountId: fromAccountId,
        type: TransactionType.transfer,
        amount: amount,
        description: description,
        timestamp: DateTime.now(),
        status: TransactionStatus.completed,
        recipientId: toAccountId,
        recipientName: recipientName,
      );

      final incomingTransaction = Transaction(
        id: _uuid.v4(),
        accountId: toAccountId,
        type: TransactionType.transfer,
        amount: amount,
        description: 'Transfer dari ${_authService.currentUser?.name}',
        timestamp: DateTime.now(),
        status: TransactionStatus.completed,
        recipientId: fromAccountId,
        recipientName: _authService.currentUser?.name,
      );

      _transactions.add(outgoingTransaction);
      _transactions.add(incomingTransaction);

      Logger.info(
          'AccountService: Transfer berhasil dari rekening $fromAccountId ke $toAccountId: ${amount.toStringAsFixed(0)}');
      return true;
    } catch (e) {
      Logger.error('AccountService: Error saat melakukan transfer: $e');
      return false;
    }
  }

  // memproses pembayaran dari rekening
  // mengembalikan true jika berhasil, false jika gagal
  Future<bool> makePayment(
      String accountId, double amount, String description) async {
    try {
      final account = _accounts[accountId];
      if (account == null) {
        Logger.warning(
            'AccountService: Rekening tidak ditemukan untuk pembayaran: $accountId');
        return false;
      }

      // memeriksa apakah saldo mencukupi
      if (account.balance < amount) {
        Logger.warning(
            'AccountService: Saldo tidak mencukupi untuk pembayaran: ${account.balance} < $amount');
        return false;
      }

      // mengupdate saldo rekening
      account.balance -= amount;

      // membuat catatan transaksi
      final transaction = Transaction(
        id: _uuid.v4(),
        accountId: accountId,
        type: TransactionType.payment,
        amount: amount,
        description: description,
        timestamp: DateTime.now(),
        status: TransactionStatus.completed,
      );

      _transactions.add(transaction);

      Logger.info(
          'AccountService: Pembayaran berhasil dari rekening $accountId: ${amount.toStringAsFixed(0)}');
      return true;
    } catch (e) {
      Logger.error('AccountService: Error saat melakukan pembayaran: $e');
      return false;
    }
  }
}
