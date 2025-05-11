import 'package:logging/logging.dart';

class LoggerService {
  static final Logger _logger = Logger('BankApp');
  static bool _initialized = false;

  static void init() {
    if (!_initialized) {
      Logger.root.level = Level.ALL;
      Logger.root.onRecord.listen((record) {
        // Dalam mode development, tetap tampilkan di console
        if (const bool.fromEnvironment('dart.vm.product')) {
          // TODO: Implement production logging (e.g., to file or service)
        } else {
          print('${record.level.name}: ${record.time}: ${record.message}');
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
