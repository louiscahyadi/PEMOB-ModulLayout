import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../utils/currency_formatter.dart';
import '../utils/date_formatter.dart';

// mengimplementasikan widget untuk menampilkan item transaksi dalam daftar
// digunakan sebagai komponen untuk menampilkan informasi transaksi secara individual
class TransactionItem extends StatelessWidget {
  // menyimpan data transaksi yang akan ditampilkan
  final Transaction transaction;

  // mengontrol tampilan detail transaksi
  final bool showDetails;

  // menginisialisasi widget transaction item dengan data yang diperlukan
  const TransactionItem({
    super.key,
    required this.transaction,
    this.showDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (!showDetails) {
          _showTransactionDetails(context);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            _buildTransactionIcon(),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getTransactionTitle(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    transaction.description,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12.0,
                    ),
                  ),
                  if (showDetails && transaction.recipientName != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        'Penerima: ${transaction.recipientName}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12.0,
                        ),
                      ),
                    ),
                  if (showDetails)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        DateFormatter.formatDateTime(transaction.timestamp),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12.0,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _getAmountText(),
                  style: TextStyle(
                    color: _getAmountColor(),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!showDetails)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      DateFormatter.formatRelative(transaction.timestamp),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12.0,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // membangun tampilan ikon berdasarkan tipe transaksi yang diberikan
  Widget _buildTransactionIcon() {
    IconData icon;
    Color color;

    switch (transaction.type) {
      case TransactionType.deposit:
        icon = Icons.arrow_downward;
        color = Colors.green;
        break;
      case TransactionType.withdrawal:
        icon = Icons.arrow_upward;
        color = Colors.red;
        break;
      case TransactionType.transfer:
        icon = Icons.swap_horiz;
        color = Colors.blue;
        break;
      case TransactionType.payment:
        icon = Icons.payment;
        color = Colors.orange;
        break;
      case TransactionType.loan:
        icon = Icons.account_balance;
        color = Colors.purple;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: color
            .withAlpha(51), // 0.2 opacity = 51 dalam skala alpha (255 * 0.2)
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: color,
        size: 20.0,
      ),
    );
  }

  // mengambil judul transaksi berdasarkan tipe transaksi yang ada
  String _getTransactionTitle() {
    switch (transaction.type) {
      case TransactionType.deposit:
        return 'Setoran';
      case TransactionType.withdrawal:
        return 'Penarikan';
      case TransactionType.transfer:
        return transaction.recipientName != null
            ? 'Transfer ke ${transaction.recipientName}'
            : 'Transfer';
      case TransactionType.payment:
        return 'Pembayaran';
      case TransactionType.loan:
        return 'Pinjaman';
    }
  }

  // memformat teks jumlah transaksi dengan prefix yang sesuai
  String _getAmountText() {
    final prefix = _isIncoming() ? '+ ' : '- ';
    return prefix + CurrencyFormatter.format(transaction.amount);
  }

  // menentukan warna untuk jumlah transaksi berdasarkan tipe
  Color _getAmountColor() {
    return _isIncoming() ? Colors.green : Colors.red;
  }

  // memeriksa apakah transaksi merupakan transaksi pemasukan
  bool _isIncoming() {
    return transaction.type == TransactionType.deposit ||
        (transaction.type == TransactionType.transfer &&
            transaction.recipientId == null);
  }

  // menampilkan dialog bottom sheet untuk detail transaksi
  void _showTransactionDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.0,
                height: 4.0,
                margin: const EdgeInsets.only(bottom: 16.0),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2.0),
                ),
              ),
            ),
            const Text(
              'Detail Transaksi',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            _buildDetailItem('Jenis Transaksi', _getTransactionTitle()),
            _buildDetailItem(
                'Jumlah', CurrencyFormatter.format(transaction.amount)),
            _buildDetailItem(
                'Tanggal', DateFormatter.formatDateTime(transaction.timestamp)),
            _buildDetailItem('Keterangan', transaction.description),
            if (transaction.recipientName != null)
              _buildDetailItem('Penerima', transaction.recipientName!),
            _buildDetailItem('Status', _getStatusText()),
            const SizedBox(height: 16.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF706D54),
                ),
                child: const Text('Tutup'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // membangun tampilan item detail dengan label dan nilai
  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.0,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // mengambil teks status transaksi berdasarkan enum status
  String _getStatusText() {
    switch (transaction.status) {
      case TransactionStatus.pending:
        return 'Menunggu';
      case TransactionStatus.completed:
        return 'Berhasil';
      case TransactionStatus.failed:
        return 'Gagal';
      case TransactionStatus.cancelled:
        return 'Dibatalkan';
    }
  }
}
