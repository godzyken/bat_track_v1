import 'dart:developer' as developer;
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../../models/data/adapter/typedefs.dart';
import '../../../models/data/state_wrapper/analitics/crashlytics_wrapper.dart';

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

  void logWarning(dynamic warning, {String? context}) {
    logger.w('Warning in $context:$warning');
    Sentry.captureMessage(warning);
  }

  void logInfo(dynamic info, {String? context}) {
    logger.i('Info in $context:$info');
    Sentry.captureMessage(info);
  }

  void logDebug(dynamic debug, {String? context}) {
    logger.d('Debug in $context:$debug');
    Sentry.captureMessage(debug);
  }

  void logVerbose(dynamic verbose, {String? context}) {
    logger.t('Verbose in $context:$verbose');
    Sentry.captureMessage(verbose);
  }

  void catcherFlutterError(Reader read) {
    FlutterError.onError = (details) {
      FlutterError.presentError(details);
      read(
        loggerProvider,
      ).e('Flutter Error', error: details.exception, stackTrace: details.stack);
      CrashlyticsWrapper.captureException(
        details.exception,
        details.stack ?? StackTrace.fromString(details.stack.toString()),
        read,
      );
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      try {
        read(
          loggerProvider,
        ).e('Platform Error', error: error, stackTrace: stack);
        SentryWrapper.captureException(error, stack);
      } catch (e, s) {
        developer.log('Erreur lors de la capture Sentry: $e', stackTrace: s);
      }
      return true;
    };
  }
}
