import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class CrashlyticsWrapper {
  static Future<void> captureException(
    Object exception,
    StackTrace stack, {
    String? hint,
  }) async {
    await FirebaseCrashlytics.instance.recordError(
      exception,
      stack,
      reason: hint,
      fatal: false,
    );
  }
}
