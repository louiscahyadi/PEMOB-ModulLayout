import 'package:flutter/material.dart';
import '../models/account.dart';
import '../services/account_service.dart';
import '../services/notification_service.dart';
import '../utils/currency_formatter.dart';

class WithdrawScreen extends StatefulWidget {
  final Account account;

  const WithdrawScreen({
    super.key,
    required this.account,
  });

  @override
  State<WithdrawScreen> createState() => _WithdrawScreenState();
}

class _WithdrawScreenState extends State<WithdrawScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  final AccountService _accountService = AccountService();
  final NotificationService _notificationService = NotificationService();

  bool _isLoading = false;
  bool _isSuccess = false;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _withdraw() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final amount = double.parse(_amountController.text.replaceAll('.', ''));

      final success = await _accountService.withdraw(
        widget.account.id,
        amount,
        _descriptionController.text.isEmpty
            ? 'Penarikan'
            : _descriptionController.text,
      );

      if (success) {
        // Menampilkan notifikasi
        await _notificationService.showTransactionNotification(
          'Penarikan Berhasil',
          'Penarikan sebesar ${CurrencyFormatter.format(amount)} berhasil',
        );

        setState(() {
          _isSuccess = true;
          _isLoading = false;
        });
      } else {
        _showErrorDialog('Saldo tidak mencukupi atau terjadi kesalahan');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error during withdrawal: ${e.toString()}');
      String errorMessage = 'Terjadi kesalahan saat melakukan penarikan.';

      if (e is FormatException) {
        errorMessage = 'Format jumlah penarikan tidak valid.';
      } else if (e is Exception) {
        errorMessage = e.toString();
      }

      _showErrorDialog(errorMessage);
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text(
              'OK',
              style: TextStyle(color: Color(0xFF4B5563)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F2937),
        title: const Text('Penarikan'),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isSuccess ? _buildSuccessView() : _buildWithdrawForm(),
    );
  }

  Widget _buildWithdrawForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // menampilkan informasi saldo pengguna
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: const Color(0xFF374151),
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.account_balance_wallet,
                    color: Colors.white,
                    size: 32.0,
                  ),
                  const SizedBox(width: 16.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Saldo Anda',
                        style: TextStyle(
                          fontSize: 14.0,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        CurrencyFormatter.format(widget.account.balance),
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24.0),

            // membangun form input penarikan
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: const Color(0xFFD1D5DB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Jumlah Penarikan',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 16.0,
                      ),
                      prefixText: 'Rp. ',
                      hintText: '0',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Jumlah penarikan tidak boleh kosong';
                      }

                      try {
                        final amount = double.parse(value.replaceAll('.', ''));
                        if (amount <= 0) {
                          return 'Jumlah penarikan harus lebih dari 0';
                        }
                        if (amount > widget.account.balance) {
                          return 'Saldo tidak mencukupi';
                        }
                      } catch (e) {
                        return 'Jumlah penarikan tidak valid';
                      }

                      return null;
                    },
                    onChanged: (value) {
                      // Format currency as user types
                      if (value.isNotEmpty) {
                        try {
                          final amount =
                              double.parse(value.replaceAll('.', ''));
                          final formatted = CurrencyFormatter.format(amount)
                              .replaceAll('Rp. ', '');

                          _amountController.value = TextEditingValue(
                            text: formatted,
                            selection: TextSelection.collapsed(
                                offset: formatted.length),
                          );
                        } catch (e) {
                          // Ignore formatting errors
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 16.0),
                  const Text(
                    'Keterangan',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 16.0,
                      ),
                      hintText: 'Masukkan keterangan (opsional)',
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24.0),

            // menambahkan tombol untuk melakukan penarikan
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1F2937),
                ),
                onPressed: _isLoading ? null : _withdraw,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.0,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Tarik'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // membangun tampilan sukses setelah penarikan berhasil
  Widget _buildSuccessView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Color(0xFF4B5563),
              size: 80.0,
            ),
            const SizedBox(height: 24.0),
            const Text(
              'Penarikan Berhasil',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16.0),
            Text(
              'Penarikan sebesar ${CurrencyFormatter.format(double.parse(_amountController.text.replaceAll('.', '')))} telah berhasil',
              style: const TextStyle(
                fontSize: 16.0,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1F2937),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Kembali ke Beranda'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
