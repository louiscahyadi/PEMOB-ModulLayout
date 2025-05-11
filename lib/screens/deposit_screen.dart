import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../models/account.dart';
import '../services/account_service.dart';
import '../services/notification_service.dart';
import '../utils/currency_formatter.dart';

class DepositScreen extends StatefulWidget {
  final Account account;

  const DepositScreen({
    super.key,
    required this.account,
  });

  @override
  State<DepositScreen> createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _logger = Logger();

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

  Future<void> _deposit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final amount = double.parse(_amountController.text.replaceAll('.', ''));

      final success = await _accountService.deposit(
        widget.account.id,
        amount,
        _descriptionController.text.isEmpty
            ? 'Setoran'
            : _descriptionController.text,
      );

      if (success) {
        // Show notification
        await _notificationService.showTransactionNotification(
          'Setoran Berhasil',
          'Setoran sebesar ${CurrencyFormatter.format(amount)} berhasil',
        );

        setState(() {
          _isSuccess = true;
          _isLoading = false;
        });
      } else {
        _showErrorDialog('Terjadi kesalahan saat melakukan setoran');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      _logger.e('Error depositing: $e'); // Replace print with logger.e
      _showErrorDialog('Terjadi kesalahan. Silakan coba lagi.');
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
              style: TextStyle(color: Color(0xFF706D54)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF706D54),
        title: const Text('Deposito'),
        centerTitle: true,
      ),
      body: _isSuccess ? _buildSuccessView() : _buildDepositForm(),
    );
  }

  Widget _buildDepositForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Saldo
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.account_balance_wallet,
                    color: Color(0xFF706D54),
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
                        ),
                      ),
                      Text(
                        CurrencyFormatter.format(widget.account.balance),
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24.0),

            // Form Deposit
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFA08963).withValues(
                      red: 160,  // 0xA0
                      green: 137, // 0x89
                      blue: 99,  // 0x63
                      alpha: 77, // 0.3 * 255 ≈ 77
                    ),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Jumlah Setoran',
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
                        return 'Jumlah setoran tidak boleh kosong';
                      }

                      try {
                        final amount = double.parse(value.replaceAll('.', ''));
                        if (amount <= 0) {
                          return 'Jumlah setoran harus lebih dari 0';
                        }
                      } catch (e) {
                        return 'Jumlah setoran tidak valid';
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

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _deposit,
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
                    : const Text('Setor'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              color: Color(0xFF706D54),
              size: 80.0,
            ),
            const SizedBox(height: 24.0),
            const Text(
              'Setoran Berhasil',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16.0),
            Text(
              'Setoran sebesar ${CurrencyFormatter.format(double.parse(_amountController.text.replaceAll('.', '')))} telah berhasil',
              style: const TextStyle(
                fontSize: 16.0,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
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
