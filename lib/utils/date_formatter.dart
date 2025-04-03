import 'package:intl/intl.dart';

// utils untuk memformat tanggal dan waktu
class DateFormatter {
  // Memformat tanggal menjadi format "dd MMM yyyy" dalam bahasa indonesia
  // Returns string tanggal yang diformat
  static String formatDate(DateTime date) {
    final formatter = DateFormat('dd MMM yyyy', 'id_ID');
    return formatter.format(date);
  }

  // memformat tanggal dan waktu menjadi format "dd MMM yyyy, HH:mm" dalam bahasa indonesia
  // returns string tanggal dan waktu yang diformat
  static String formatDateTime(DateTime date) {
    final formatter = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');
    return formatter.format(date);
  }

  // memformat tanggal menjadi format relatif terhadap waktu sekarang
  // returns string waktu relatif
  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return formatDate(date);
    } else if (difference.inDays > 0) {
      return '${difference.inDays} hari yang lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit yang lalu';
    } else {
      return 'Baru saja';
    }
  }

  // memformat tanggal menjadi format "EEEE, dd MMMM yyyy" dalam bahasa indonesia
  // returns string tanggal lengkap
  static String formatFullDate(DateTime date) {
    final formatter = DateFormat('EEEE, dd MMMM yyyy', 'id_ID');
    return formatter.format(date);
  }
}
