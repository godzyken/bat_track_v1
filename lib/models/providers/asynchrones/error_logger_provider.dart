import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Un logger centralisé utilisable partout via Riverpod
final errorLoggerProvider = Provider<ErrorLogger>((ref) => ErrorLogger());

class ErrorLogger {
  /// Envoie une erreur à Sentry
  Future<void> logError(
    dynamic error, [
    StackTrace? stackTrace,
    String? context,
  ]) async {
    developer.log('🚨 [\$context] \$error');
    await Sentry.captureException(
      error,
      stackTrace: stackTrace,
      hint: context != null ? Hint.withMap({'context': context}) : null,
    );
  }

  /// Simple log d'information
  void logInfo(String message) {
    developer.log('ℹ️ \$message');
    Sentry.captureMessage(message);
  }

  /// Log de warning
  void logWarning(String message) {
    developer.log('⚠️ \$message');
    Sentry.captureMessage(message);
  }

  /// Log de debug
  void logDebug(String message) {
    developer.log('🔎 \$message');
    Sentry.captureMessage(message);
  }
}
