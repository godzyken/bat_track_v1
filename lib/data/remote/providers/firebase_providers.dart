import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../firebase_options.dart';

final firebaseInitializationProvider = FutureProvider<FirebaseApp>((ref) async {
  final app = await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 🔧 Active la persistance Firestore une seule fois
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );

  return app;
});

final firebaseStorageProvider = Provider<FirebaseStorage>((ref) {
  return FirebaseStorage.instance;
});
