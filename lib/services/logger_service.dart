import 'package:logging/logging.dart';

// mengimplementasikan layanan logging untuk aplikasi bank
// menyediakan fungsi-fungsi untuk mencatat berbagai level log
class LoggerService {
  static final Logger _logger = Logger('BankApp');
  static bool _initialized = false;

  // menginisialisasi konfigurasi logger
  // mengatur level log dan listener untuk mencatat pesan
  static void init() {
    if (!_initialized) {
      Logger.root.level = Level.ALL;
      Logger.root.onRecord.listen((record) {
        String logMessage = _formatLogMessage(record);
        try {
          print(logMessage);
        } catch (e) {
          print('Logging failed: $e');
        }
      });
      _initialized = true;
    }
  }

  // memformat pesan log dengan format yang sesuai
  // @param record - record log yang akan diformat
  // @return string hasil format log
  static String _formatLogMessage(LogRecord record) {
    return '${record.level.name}: ${record.time}: ${record.message}'
        '${record.error != null ? '\nError: ${record.error}' : ''}'
        '${record.stackTrace != null ? '\nStack: ${record.stackTrace}' : ''}';
  }

  // mencatat pesan error dengan level severe
  // @param message - pesan error yang akan dicatat
  // @param error - objek error (opsional)
  // @param stackTrace - stack trace error (opsional)
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.severe(message, error, stackTrace);
  }

  // mencatat pesan informasi dengan level info
  // @param message - pesan informasi yang akan dicatat
  static void info(String message) {
    _logger.info(message);
  }

  // mencatat pesan peringatan dengan level warning
  // @param message - pesan peringatan yang akan dicatat
  static void warning(String message) {
    _logger.warning(message);
  }

  // mencatat pesan debug dengan level fine
  // @param message - pesan debug yang akan dicatat
  static void debug(String message) {
    _logger.fine(message);
  }
}
