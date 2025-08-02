import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

enum LogLevel { debug, info, warning, error }

class AppLogger {
  const AppLogger();

  void log(
    String message, {
    LogLevel level = LogLevel.info,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final prefix = switch (level) {
      LogLevel.debug => '[DEBUG]',
      LogLevel.info => '[INFO]',
      LogLevel.warning => '[WARNING]',
      LogLevel.error => '[ERROR]',
    };

    debugPrint('$prefix $message');

    if (level == LogLevel.error || level == LogLevel.warning) {
      Sentry.captureMessage(
        '$prefix $message',
        level:
            level == LogLevel.error ? SentryLevel.error : SentryLevel.warning,
      );
      if (error != null) {
        Sentry.captureException(error, stackTrace: stackTrace);
      }
    }
  }

  void debug(String message) => log(message, level: LogLevel.debug);

  void info(String message) => log(message, level: LogLevel.info);

  void warning(String message, {Object? error, StackTrace? stackTrace}) => log(
    message,
    level: LogLevel.warning,
    error: error,
    stackTrace: stackTrace,
  );

  void error(String message, {Object? error, StackTrace? stackTrace}) =>
      log(message, level: LogLevel.error, error: error, stackTrace: stackTrace);
}

extension AppLoggerEvents on AppLogger {
  void logEvent(String name, {Map<String, dynamic>? properties}) {
    final message =
        '[EVENT] $name ${properties != null ? properties.toString() : ""}';
    debugPrint(message);

    Sentry.captureMessage(message, level: SentryLevel.info);

    Sentry.captureEvent(
      SentryEvent(
        message: SentryMessage(message),
        unknown: properties,
        tags: {'event_type': 'business'},
      ),
    );
  }

  void logAction(String action, {String? target, Map<String, dynamic>? data}) {
    final message = '[ACTION] $action on ${target ?? 'unknown'}';
    debugPrint(message);

    Sentry.captureEvent(
      SentryEvent(
        message: SentryMessage(message),
        unknown: {'target': target, ...?data},
        tags: {'event_type': 'user_action'},
      ),
    );
  }
}
