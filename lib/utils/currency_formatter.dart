import 'package:intl/intl.dart';

// utils untuk memformat angka menjadi format mata uang
class CurrencyFormatter {
  // memformat angka menjadi format mata uang rupiah
  // returns string dalam format mata uang rupiah
  static String format(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp. ',
      decimalDigits: 0,
    );

    return formatter.format(amount);
  }

  // memformat angka menjadi format mata uang rupiah tanpa simbol
  // returns string dalam format mata uang rupiah tanpa simbol
  static String formatWithoutSymbol(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: '',
      decimalDigits: 0,
    );

    return formatter.format(amount).trim();
  }

  // mengkonversi string format mata uang menjadi double
  // returns nilai double dari string yang diformat
  static double parse(String formattedAmount) {
    // menghapus semua karakter non-digit kecuali tanda desimal
    final cleanString = formattedAmount.replaceAll(RegExp(r'[^\d.]'), '');
    return double.parse(cleanString);
  }
}
