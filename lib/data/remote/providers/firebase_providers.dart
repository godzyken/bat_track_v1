import 'package:bat_track_v1/data/remote/providers/catch_error_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../../../firebase_options.dart';

final firebaseInitializationProvider = FutureProvider<FirebaseApp>((ref) async {
  final logger = ref.watch(loggerProvider);
  try {
    final options = DefaultFirebaseOptions.currentPlatform;
    if (options == null) throw Exception('FirebaseOptions is null');

    final app = await Firebase.initializeApp(options: options);

    if (!kIsWeb) {
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    }

    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
    );

    await SentryFlutter.init((options) {
      options.dsn =
          'https://20443e8de2a733fa13a6097a41419cbf@o4505047063592960.ingest.us.sentry.io/4509839378350080';
      // Set tracesSampleRate to 1.0 to capture 100% of transactions for tracing.
      // We recommend adjusting this value in production.
      options.tracesSampleRate = 1.0;
      // The sampling rate for profiling is relative to tracesSampleRate
      // Setting to 1.0 will profile 100% of sampled transactions:
      options.profilesSampleRate = 1.0;
    }, appRunner: () {});

    return app;
  } catch (e, st) {
    logger.e("Erreur critique", error: e, stackTrace: st);
    await Sentry.captureException(e, stackTrace: st);
    rethrow;
  }
});

final firebaseStorageProvider = Provider<FirebaseStorage>((ref) {
  return FirebaseStorage.instance;
});
