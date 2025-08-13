import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/services/hive_service.dart';
import '../data/remote/providers/firebase_providers.dart';
import '../data/remote/services/firestore_service.dart';
import '../data/remote/services/storage_service.dart';

final hiveServiceProvider = Provider<HiveService>((ref) => HiveService());

final firestoreServiceProvider = Provider<FirestoreService>(
  (ref) => FirestoreService(),
);

final storageServiceProvider = Provider<StorageService>((ref) {
  final storage = ref.watch(firebaseStorageProvider);
  return StorageService(storage);
});
