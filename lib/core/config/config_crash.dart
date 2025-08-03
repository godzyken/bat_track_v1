import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../data/remote/providers/catch_error_provider.dart';

Future<void> recordFlutterError(Object error, StackTrace stack) async {
  final crashlytics = FirebaseCrashlytics.instance;
  await crashlytics.recordError(error, stack, fatal: true);
}

typedef AsyncCallback<T> = Future<T> Function();

Future<T?> catchAsync<T>(
  Ref ref,
  AsyncCallback<T> callback, {
  String? context,
  void Function(Object error, StackTrace stack)? onError,
  bool reportToSentry = true,
}) async {
  final logger = ref.read(loggerProvider);

  try {
    return await callback();
  } catch (e, st) {
    logger.e('❌ [${context ?? 'AsyncError'}] $e', error: e, stackTrace: st);
    if (reportToSentry) {
      await Sentry.captureException(e, stackTrace: st);
    }
    return null; // ou rethrow si tu veux propager
  }
}
