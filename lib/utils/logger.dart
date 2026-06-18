import 'package:logger/logger.dart';

final logger = Logger(
  level: Level.debug,
);

extension LoggerExtension on Logger {
  void logDebug(String message) => d(message);
  void logInfo(String message) => i(message);
  void logWarning(String message) => w(message);
  void logError(String message, [dynamic error, StackTrace? stackTrace]) =>
      e(message, error: error, stackTrace: stackTrace);
}
