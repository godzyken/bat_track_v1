import 'package:bat_track_v1/data/remote/providers/catch_error_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
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

    if (kIsWeb) {
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
      );
    }

    return app;
  } catch (e, st) {
    logger.e("Erreur critique", error: e, stackTrace: st);
    await Sentry.captureException(e, stackTrace: st);
    rethrow;
  }
});

Future<FirebaseApp> appInit() async {
  final app = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 🔧 Active la persistance Firestore une seule fois
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );

  return app;
}

final firebaseStorageProvider = Provider<FirebaseStorage>((ref) {
  return FirebaseStorage.instance;
});
