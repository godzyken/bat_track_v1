import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

final loggerProvider = Provider<Logger>((ref) {
  return Logger(
    printer: PrettyPrinter(
      methodCount: 1,
      errorMethodCount: 8,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );
});

final errorLoggerProvider = Provider<ErrorLogger>((ref) {
  final logger = ref.read(loggerProvider);
  return ErrorLogger(logger);
});

class ErrorLogger {
  final Logger logger;

  ErrorLogger(this.logger);

  void logError(dynamic error, StackTrace? stack, {String? context}) {
    logger.e('Error in $context', error: error, stackTrace: stack);
    Sentry.captureException(error, stackTrace: stack);
  }
}
