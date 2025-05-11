import 'package:intl/intl.dart';

// mengimplementasikan utilitas untuk memformat nilai numerik menjadi format mata uang
class CurrencyFormatter {
  // mengubah nilai numerik menjadi string format mata uang rupiah
  // mengembalikan string dalam format mata uang rupiah lengkap dengan simbol
  static String format(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp. ',
      decimalDigits: 0,
    );

    return formatter.format(amount);
  }

  // mengubah nilai numerik menjadi string format mata uang rupiah
  // mengembalikan string dalam format mata uang rupiah tanpa simbol mata uang
  static String formatWithoutSymbol(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: '',
      decimalDigits: 0,
    );

    return formatter.format(amount).trim();
  }

  // mengkonversi string format mata uang menjadi nilai numerik
  // mengembalikan nilai double dari string mata uang yang diinput
  static double parse(String formattedAmount) {
    // membersihkan string dari karakter non-numerik kecuali tanda desimal
    final cleanString = formattedAmount.replaceAll(RegExp(r'[^\d.]'), '');
    return double.parse(cleanString);
  }
}
