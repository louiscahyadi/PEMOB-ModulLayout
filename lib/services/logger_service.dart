import 'package:logging/logging.dart';

class LoggerService {
  static final Logger _logger = Logger('BankApp');
  static bool _initialized = false;

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

  static String _formatLogMessage(LogRecord record) {
    return '${record.level.name}: ${record.time}: ${record.message}'
        '${record.error != null ? '\nError: ${record.error}' : ''}'
        '${record.stackTrace != null ? '\nStack: ${record.stackTrace}' : ''}';
  }

  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    _logger.severe(message, error, stackTrace);
  }

  static void info(String message) {
    _logger.info(message);
  }

  static void warning(String message) {
    _logger.warning(message);
  }

  static void debug(String message) {
    _logger.fine(message);
  }
}
