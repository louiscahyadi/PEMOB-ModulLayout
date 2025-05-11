import 'package:flutter/material.dart';
import '../models/account.dart';
import '../services/account_service.dart';
import '../services/notification_service.dart';
import '../utils/currency_formatter.dart';
import '../utils/exceptions.dart';

class TransferScreen extends StatefulWidget {
  final Account account;

  const TransferScreen({
    super.key,
    required this.account,
  });

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _accountNumberController = TextEditingController();
  final _recipientNameController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  final AccountService _accountService = AccountService();
  final NotificationService _notificationService = NotificationService();

  bool _isLoading = false;
  bool _isSuccess = false;

  @override
  void dispose() {
    _accountNumberController.dispose();
    _recipientNameController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _transfer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final amount = double.parse(_amountController.text.replaceAll('.', ''));

      // For demo purposes, we'll simulate a transfer to a demo account
      final success = await _accountService.transfer(
        widget.account.id,
        'account2', // Demo recipient account
        _recipientNameController.text,
        amount,
        _descriptionController.text,
      );

      if (success) {
        // Show notification
        await _notificationService.showTransactionNotification(
          'Transfer Berhasil',
          'Transfer sebesar ${CurrencyFormatter.format(amount)} ke ${_recipientNameController.text} berhasil',
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
      debugPrint('Transfer error: ${e.toString()}');
      String errorMessage = 'Terjadi kesalahan pada sistem.';

      if (e is FormatException) {
        errorMessage = 'Format jumlah transfer tidak valid.';
      } else if (e is NetworkException) {
        errorMessage = e.message;
      } else if (e is TransferException) {
        errorMessage = e.message;
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
              style: TextStyle(color: Color(0xFF1F2937)),
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
        elevation: 0,
        title: const Text('Transfer'),
        centerTitle: true,
      ),
      body: _isSuccess ? _buildSuccessView() : _buildTransferForm(),
    );
  }

  Widget _buildTransferForm() {
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

            // Form Transfer
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nomor Rekening',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  TextFormField(
                    controller: _accountNumberController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 16.0,
                      ),
                      hintText: 'Masukkan nomor rekening tujuan',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nomor rekening tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  const Text(
                    'Nama Penerima',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  TextFormField(
                    controller: _recipientNameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12.0,
                        vertical: 16.0,
                      ),
                      hintText: 'Masukkan nama penerima',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama penerima tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  const Text(
                    'Jumlah Transfer',
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
                        return 'Jumlah transfer tidak boleh kosong';
                      }

                      try {
                        final amount = double.parse(value.replaceAll('.', ''));
                        if (amount <= 0) {
                          return 'Jumlah transfer harus lebih dari 0';
                        }
                        if (amount > widget.account.balance) {
                          return 'Saldo tidak mencukupi';
                        }
                      } catch (e) {
                        return 'Jumlah transfer tidak valid';
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
                onPressed: _isLoading ? null : _transfer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1F2937),
                  foregroundColor: Colors.white,
                ),
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
                    : const Text('Transfer'),
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
              color: Color(0xFF059669),
              size: 80.0,
            ),
            const SizedBox(height: 24.0),
            const Text(
              'Transfer Berhasil',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16.0),
            Text(
              'Transfer sebesar ${CurrencyFormatter.format(double.parse(_amountController.text.replaceAll('.', '')))} ke ${_recipientNameController.text} telah berhasil',
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1F2937),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Kembali ke Beranda'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
