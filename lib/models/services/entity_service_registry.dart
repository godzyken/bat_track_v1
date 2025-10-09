import 'package:bat_track_v1/models/services/remote/remote_entity_service_adapter.dart';
import 'package:bat_track_v1/models/services/remote/remote_storage_service.dart';
import 'package:bat_track_v1/models/services/synced_entity_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/core/unified_model.dart';
import '../../data/local/services/service_type.dart';
import '../providers/asynchrones/remote_service_provider.dart';
import 'hive_entity_service.dart';
import 'logged_entity_service.dart';

typedef FromJson<T> = T Function(Map<String, dynamic> json);

// Provider pour le service local+remote synchronisé (SyncedEntityService)
Provider<SyncedEntityService<T>>
buildSyncedEntityProvider<T extends UnifiedModel>({
  required String collectionOrBoxName,
  required T Function(Map<String, dynamic>) fromJson,
  RemoteStorageService? remoteService, // optionnel, permet override
  String? hiveBoxName,
}) {
  return Provider<SyncedEntityService<T>>((ref) {
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

    return SyncedEntityService<T>(localService, remoteAdapter);
  });
}

// Provider pour un service synchronisé avec logs (LoggedEntitySyncService)
Provider<LoggedEntitySyncService<T>>
buildLoggedEntitySyncServiceProvider<T extends UnifiedModel>({
  required String collectionOrBoxName,
  required T Function(Map<String, dynamic>) fromJson,
  RemoteStorageService? remoteService,
}) {
  return Provider<LoggedEntitySyncService<T>>((ref) {
    final synced = ref.watch(
      buildSyncedEntityProvider<T>(
        collectionOrBoxName: collectionOrBoxName,
        fromJson: fromJson,
        remoteService: remoteService,
      ),
    );
    return LoggedEntitySyncService<T>(synced, ref);
  });
}

// Provider pour un service local avec logs (LoggedEntityService) (sans sync)
Provider<LoggedEntityService<T>> buildLoggedEntityServiceProvider<
  T extends UnifiedModel
>({required String boxName, required FromJson<T> fromJson}) {
  return Provider<LoggedEntityService<T>>((ref) {
    final remoteStorageService = ref.watch(remoteStorageServiceProvider);
    final hiveService = EntityServices<T>(
      boxName: boxName,
      fromJson: fromJson,
      remoteStorageService: remoteStorageService,
    );
    return LoggedEntityService(hiveService, ref);
  });
}

// Provider pour les services (sans logs et sync)
EntityServices<T> buildEntityServiceProvider<T extends UnifiedModel>({
  required String collectionOrBoxName,
  required T Function(Map<String, dynamic>) fromJson,
  RemoteStorageService? remoteStorageService,
}) {
  return EntityServices<T>(
    fromJson: fromJson,
    boxName: collectionOrBoxName,
    remoteStorageService: remoteStorageService!,
  );
}
