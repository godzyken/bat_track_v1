import 'package:bat_track_v1/data/remote/providers/catch_error_provider.dart';
import 'package:bat_track_v1/models/data/maperror/logged_action.dart';
import 'package:bat_track_v1/models/data/state_wrapper/analitics/crashlytics_wrapper.dart';
import 'package:bat_track_v1/models/data/state_wrapper/wrappers_errors.dart';

import '../../../data/remote/notifiers/erreur_handling.dart';

mixin SafeAsyncMixin<T> on LoggedAction {
  late Reader _ref;

  void initSafeAsync(Reader ref) {
    this._ref = ref;
    initLogger(ref);
  }

  /// Safe call for any Future T
  Future<R> safeAsync<R>(
    Future<R> Function() callback, {
    String? context,
    bool logError = false,
    required R fallback,
  }) async {
    try {
      return await callback();
    } catch (e, stack) {
      final label = context ?? 'safe<$T>';
      await _reportError(e, stack, label, logError: logError);
      return fallback;
    }
  }

  /// Safe call for Future void
  Future<void> safeVoid(
    Future<void> Function() callback, {
    String? context,
    bool logError = false,
  }) async {
    try {
      await callback();
    } catch (e, stack) {
      final label = context ?? 'safe<$T>';
      await _reportError(e, stack, label, logError: logError);
      if (logError) rethrow;
    }
  }

  /// Internal error reporting
  Future<void> _reportError(
    Object error,
    StackTrace stack,
    String label, {
    bool logError = false,
  }) async {
    if (logError) {
      AppLogger.error(
        '[$label] ${error.runtimeType}: $error',
        error: error,
        stackTrace: stack,
      );
    }

    await CrashlyticsWrapper.captureException(error, stack, _ref);
    await SentryWrapper.captureException(error, stack, hint: label);
  }

  Future<R?> catchAsync<R>(Future<R> Function() fn, {String? context}) async {
    final logger = _ref(loggerProvider);
    final ui = _ref(uiFeedbackProvider);
    try {
      return await fn();
    } catch (error, stack) {
      logger.e('Erreur $context', error: error, stackTrace: stack);
      ui.showError('Erreur : $context');
      return null;
    }
  }
}
