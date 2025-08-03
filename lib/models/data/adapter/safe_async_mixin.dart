import 'package:bat_track_v1/models/data/maperror/logged_action.dart';
import 'package:bat_track_v1/models/data/state_wrapper/analitics/crashlytics_wrapper.dart';
import 'package:bat_track_v1/models/data/state_wrapper/wrappers_errors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

mixin SafeAsyncMixin<T> on LoggedAction {
  late Ref ref;

  void initSafeAsync(Ref ref) {
    this.ref = ref;
    initLogger(ref);
  }

  /// Safe call for any Future<T>
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

  /// Safe call for Future<void>
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

    await CrashlyticsWrapper.captureException(error, stack, hint: label);
  }
}
