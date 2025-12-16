import 'package:bat_track_v1/models/services/remote/remote_entity_service_adapter.dart';
import 'package:bat_track_v1/models/services/remote/remote_storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/unified_entity_service.dart';
import '../../data/core/unified_model.dart';
import '../providers/asynchrones/remote_service_provider.dart';
import 'hive_entity_service.dart';
import 'logged_entity_service.dart';

typedef FromJson<T> = T Function(Map<String, dynamic> json);

// Provider pour le service local+remote synchronisé (UnifiedEntityService)
Provider<UnifiedEntityService<T>>
buildSyncedEntityProvider<T extends UnifiedModel>({
  required String collectionOrBoxName,
  required T Function(Map<String, dynamic>) fromJson,
  RemoteStorageService? remoteService, // optionnel, permet override
  String? hiveBoxName,
}) {
  return Provider<UnifiedEntityService<T>>((ref) {
    final remoteStorage =
        remoteService ?? ref.watch(remoteStorageServiceProvider);
    final localService = HiveEntityService<T>(
      boxName: hiveBoxName ?? collectionOrBoxName,
      fromJson: fromJson,
    );
    final remoteAdapter = RemoteEntityServiceAdapter<T>(
      storage: remoteStorage!,
      collection: collectionOrBoxName,
      fromJson: fromJson,
    );

    return UnifiedEntityService<T>(
      collectionName: localService.boxName,
      fromJson: localService.fromJson,
      remoteStorage: remoteAdapter.storage,
    );
  });
}

// Provider pour un service synchronisé avec logs (LoggedEntitySyncService)
Provider<SafeAndLoggedEntityService<T>>
buildLoggedEntitySyncServiceProvider<T extends UnifiedModel>({
  required String collectionOrBoxName,
  required T Function(Map<String, dynamic>) fromJson,
  RemoteStorageService? remoteService,
}) {
  return Provider<SafeAndLoggedEntityService<T>>((ref) {
    final synced = ref.watch(
      buildSyncedEntityProvider<T>(
        collectionOrBoxName: collectionOrBoxName,
        fromJson: fromJson,
        remoteService: remoteService,
      ),
    );

    return SafeAndLoggedEntityService<T>(synced, ref);
  });
}

// Provider pour un service local avec logs (LoggedEntityService) (sans sync)
Provider<SafeAndLoggedEntityService<T>> buildLoggedEntityServiceProvider<
  T extends UnifiedModel
>({required String boxName, required FromJson<T> fromJson}) {
  return Provider<SafeAndLoggedEntityService<T>>((ref) {
    final remoteStorageService = ref.watch(remoteStorageServiceProvider);
    final hiveService = UnifiedEntityService<T>(
      collectionName: boxName,
      fromJson: fromJson,
      remoteStorage: remoteStorageService,
    );
    return SafeAndLoggedEntityService(hiveService, ref);
  });
}

// Provider pour les services (sans logs et sync)
UnifiedEntityService<T> buildEntityServiceProvider<T extends UnifiedModel>({
  required String collectionOrBoxName,
  required T Function(Map<String, dynamic>) fromJson,
  RemoteStorageService? remoteStorageService,
}) {
  return UnifiedEntityService<T>(
    fromJson: fromJson,
    collectionName: collectionOrBoxName,
    remoteStorage: remoteStorageService!,
  );
}
