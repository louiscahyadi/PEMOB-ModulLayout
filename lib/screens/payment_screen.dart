import 'package:flutter/material.dart';
import '../models/account.dart';
import '../services/account_service.dart';
import '../services/notification_service.dart';
import '../services/logger_service.dart';
import '../utils/currency_formatter.dart';

class PaymentScreen extends StatefulWidget {
  final Account account;

  const PaymentScreen({
    super.key,
    required this.account,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  final AccountService _accountService = AccountService();
  final NotificationService _notificationService = NotificationService();

  String _selectedCategory = 'Listrik';
  final List<String> _categories = [
    'Listrik',
    'Air',
    'Internet',
    'Telepon',
    'Pendidikan',
    'Asuransi',
    'Lainnya',
  ];

  bool _isLoading = false;
  bool _isSuccess = false;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _makePayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final amount = double.parse(_amountController.text.replaceAll('.', ''));

      final description = _descriptionController.text.isEmpty
          ? 'Pembayaran $_selectedCategory'
          : _descriptionController.text;

      final success = await _accountService.makePayment(
        widget.account.id,
        amount,
        description,
      );

      if (success) {
        // Show notification
        await _notificationService.showTransactionNotification(
          'Pembayaran Berhasil',
          'Pembayaran $_selectedCategory sebesar ${CurrencyFormatter.format(amount)} berhasil',
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
      LoggerService.error('Error making payment', e);
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
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F2937),
        title: const Text('Pembayaran'),
        centerTitle: true,
        elevation: 0,
      ),
      body: _isSuccess ? _buildSuccessView() : _buildPaymentForm(),
    );
  }

  Widget _buildPaymentForm() {
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
                color: const Color(0xFF1F2937),
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

            // Form Pembayaran
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
                    'Kategori Pembayaran',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCategory,
                        isExpanded: true,
                        icon: const Icon(Icons.arrow_drop_down),
                        iconSize: 24,
                        elevation: 16,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16.0,
                        ),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedCategory = newValue!;
                          });
                        },
                        items: _categories
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  const Text(
                    'Jumlah Pembayaran',
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
                        return 'Jumlah pembayaran tidak boleh kosong';
                      }

                      try {
                        final amount = double.parse(value.replaceAll('.', ''));
                        if (amount <= 0) {
                          return 'Jumlah pembayaran harus lebih dari 0';
                        }
                        if (amount > widget.account.balance) {
                          return 'Saldo tidak mencukupi';
                        }
                      } catch (e) {
                        return 'Jumlah pembayaran tidak valid';
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
                onPressed: _isLoading ? null : _makePayment,
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
                    : const Text('Bayar'),
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
              color: Color(0xFF1F2937),
              size: 80.0,
            ),
            const SizedBox(height: 24.0),
            const Text(
              'Pembayaran Berhasil',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16.0),
            Text(
              'Pembayaran $_selectedCategory sebesar ${CurrencyFormatter.format(double.parse(_amountController.text.replaceAll('.', '')))} telah berhasil',
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
