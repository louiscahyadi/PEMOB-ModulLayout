import 'package:flutter/foundation.dart';

// pindahkan enum Level ke luar kelas logger
// level logging
enum LogLevel {
  debug,
  info,
  warning,
  error,
}

// utils untuk logging aplikasi
// class untuk method logging dengan berbagai level
// seperti info, warning, error, dan debug.
class Logger {
  // level minimum yang akan ditampilkan
  static LogLevel _minLevel = kDebugMode ? LogLevel.debug : LogLevel.info;

  // mengatur level minimum yang akan ditampilkan
  static void setMinLevel(LogLevel level) {
    _minLevel = level;
  }

  // log pesan dengan level debug
  static void debug(String message) {
    if (_minLevel.index <= LogLevel.debug.index) {
      _log('DEBUG', message);
    }
  }

  // log pesan dengan level info
  static void info(String message) {
    if (_minLevel.index <= LogLevel.info.index) {
      _log('INFO', message);
    }
  }

  // log pesan dengan level warning
  static void warning(String message) {
    if (_minLevel.index <= LogLevel.warning.index) {
      _log('WARNING', message);
    }
  }

  // log pesan dengan level error
  static void error(String message) {
    if (_minLevel.index <= LogLevel.error.index) {
      _log('ERROR', message);
    }
  }

  // method internal untuk logging
  static void _log(String level, String message) {
    final timestamp = DateTime.now().toString().split('.').first;
    debugPrint('[$timestamp] [$level] $message');
  }
}
