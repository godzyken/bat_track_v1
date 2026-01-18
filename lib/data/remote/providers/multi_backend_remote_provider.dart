import 'package:bat_track_v1/data/remote/services/firestore_service.dart';
import 'package:bat_track_v1/models/services/remote/remote_storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/services/multi_backend_remote_service.dart';
import '../../local/services/service_type.dart';
import '../services/cloud_flare_service.dart';
import '../services/firebase_service.dart';

final multiBackendRemoteProvider = Provider<RemoteStorageService>((ref) {
  // 1. Définir quels backends sont activés (via AppConfig ou un autre Provider)
  final allEnabled = AppConfig.enabledBackends;

  // 2. Mapper les services vers leurs instances respectives
  // ref.watch permet de reconstruire le multi-backend si un sous-service change
  final remoteModes = allEnabled.where((m) => m != StorageMode.hive).toList();

  final backends = <StorageMode, RemoteStorageService>{
    if (remoteModes.contains(StorageMode.firestore))
      StorageMode.firestore: ref.watch(firestoreServiceProvider),

    if (remoteModes.contains(StorageMode.cloudflare))
      StorageMode.cloudflare: ref.watch(cloudFlareServiceProvider),

    if (remoteModes.contains(StorageMode.firebase))
      StorageMode.firebase: ref.watch(firebaseServiceProvider),
  };

  return MultiBackendRemoteService(
    enabledBackends: remoteModes,
    backends: backends,
  );
});

final cloudFlareServiceProvider = Provider<RemoteStorageService>((ref) {
  // On retourne l'instance singleton de ton service
  return CloudFlareService.instance;
});

final firestoreServiceProvider = Provider<RemoteStorageService>((ref) {
  // On retourne l'instance singleton de ton service
  return FirestoreService();
});

final firebaseServiceProvider = Provider<RemoteStorageService>((ref) {
  return FirebaseService.instance;
});
