import 'package:logging/logging.dart';

class LoggerService {
  static final Logger _logger = Logger('BankApp');
  static bool _initialized = false;

  static void init() {
    if (!_initialized) {
      Logger.root.level = Level.ALL;
      Logger.root.onRecord.listen((record) {
        // menggunakan format yang konsisten untuk production dan development
        String logMessage =
            '${record.level.name}: ${record.time}: ${record.message}';
        if (const bool.fromEnvironment('dart.vm.product')) {
          // menambahkan logging untuk production
          // untuk kebutuhan, menulis ke file atau service monitoring
          print(logMessage);
        } else {
          print(logMessage);
        }
      });
      _initialized = true;
    }
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
}
