import 'package:firebase_crashlytics/firebase_crashlytics.dart';

Future<void> recordFlutterError(Object error, StackTrace stack) async {
  final crashlytics = FirebaseCrashlytics.instance;
  await crashlytics.recordError(error, stack, fatal: true);
}
