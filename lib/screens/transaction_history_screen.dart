import 'package:flutter/material.dart';
import '../models/account.dart';
import '../models/transaction.dart';
import '../services/account_service.dart';
import '../widgets/transaction_item.dart';

class TransactionHistoryScreen extends StatefulWidget {
  final Account account;

  const TransactionHistoryScreen({
    super.key,
    required this.account,
  });

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final AccountService _accountService = AccountService();

  List<Transaction> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final transactions =
          await _accountService.getTransactions(widget.account.id, limit: 50);

      setState(() {
        _transactions = transactions;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat transaksi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
          0xFFF9FAFB), // mengatur warna latar belakang menjadi lebih terang
      appBar: AppBar(
        backgroundColor:
            const Color(0xFF1F2937), // mengatur warna utama aplikasi
        title: const Text('Riwayat Transaksi'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    Color(0xFF374151)), // mengatur warna indikator loading
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadTransactions,
              color: const Color(0xFF1F2937), // menyesuaikan dengan warna utama
              child: _transactions.isEmpty
                  ? const Center(
                      child: Text(
                        'Belum ada transaksi',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _transactions.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        return TransactionItem(
                          transaction: _transactions[index],
                          showDetails: true,
                        );
                      },
                    ),
            ),
    );
  }
}
