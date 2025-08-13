import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../data/local/services/hive_service.dart';
import '../data/remote/providers/firebase_providers.dart';
import '../data/remote/services/base_storage_service.dart';
import '../data/remote/services/firebase_storage_service.dart';
import '../data/remote/services/firestore_service.dart';

final hiveServiceProvider = Provider<HiveService>((ref) => HiveService());

final firestoreServiceProvider = Provider<FirestoreService>(
  (ref) => FirestoreService(),
);

final dioProvider = Provider<Dio>((ref) => Dio());
final loggerProvider = Provider<Logger>((ref) => Logger());

final storageServiceProvider = Provider<BaseStorageService>((ref) {
  final storage = ref.watch(firebaseStorageProvider);
  final dio = ref.watch(dioProvider);
  final logger = ref.watch(loggerProvider);
  return FirebaseStorageService(storage, dio, logger);
});
