import 'package:flutter/foundation.dart';

// mendefinisikan enum untuk tingkat log yang tersedia
enum LogLevel {
  debug,
  info,
  warning,
  error,
}

// mengimplementasikan kelas utilitas untuk mengelola log aplikasi
// menyediakan fungsi logging dengan berbagai tingkat prioritas
class Logger {
  // menentukan tingkat minimum log yang akan ditampilkan
  static LogLevel _minLevel = kDebugMode ? LogLevel.debug : LogLevel.info;

  // mengatur tingkat minimum log yang akan diproses
  static void setMinLevel(LogLevel level) {
    _minLevel = level;
  }

  // mencatat pesan dengan tingkat debug
  static void debug(String message) {
    if (_minLevel.index <= LogLevel.debug.index) {
      _log('DEBUG', message);
    }
  }

  // mencatat pesan dengan tingkat info
  static void info(String message) {
    if (_minLevel.index <= LogLevel.info.index) {
      _log('INFO', message);
    }
  }

  // mencatat pesan dengan tingkat warning
  static void warning(String message) {
    if (_minLevel.index <= LogLevel.warning.index) {
      _log('WARNING', message);
    }
  }

  // mencatat pesan dengan tingkat error
  static void error(String message) {
    if (_minLevel.index <= LogLevel.error.index) {
      _log('ERROR', message);
    }
  }

  // memproses dan menampilkan pesan log dengan format yang sesuai
  static void _log(String level, String message) {
    final timestamp = DateTime.now().toString().split('.').first;
    debugPrint('[$timestamp] [$level] $message');
  }
}
