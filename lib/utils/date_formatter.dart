import 'package:intl/intl.dart';

/// mengimplementasikan utilitas untuk memformat tanggal dan waktu
class DateFormatter {
  /// mengonversi tanggal ke format "dd MMM yyyy" dalam bahasa indonesia
  /// @param date tanggal yang akan diformat
  /// @return string hasil format tanggal
  static String formatDate(DateTime date) {
    final formatter = DateFormat('dd MMM yyyy', 'id_ID');
    return formatter.format(date);
  }

  /// mengonversi tanggal dan waktu ke format "dd MMM yyyy, HH:mm" dalam bahasa indonesia
  /// @param date tanggal yang akan diformat
  /// @return string hasil format tanggal dan waktu
  static String formatDateTime(DateTime date) {
    final formatter = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');
    return formatter.format(date);
  }

  /// mengonversi tanggal menjadi format waktu relatif terhadap waktu sekarang
  /// @param date tanggal yang akan diformat
  /// @return string waktu relatif dalam bahasa indonesia
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

  /// mengonversi tanggal ke format lengkap "EEEE, dd MMMM yyyy" dalam bahasa indonesia
  /// @param date tanggal yang akan diformat
  /// @return string hasil format tanggal lengkap
  static String formatFullDate(DateTime date) {
    final formatter = DateFormat('EEEE, dd MMMM yyyy', 'id_ID');
    return formatter.format(date);
  }
}
