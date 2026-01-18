import 'package:bat_track_v1/data/local/services/service_type.dart';
import 'package:bat_track_v1/data/remote/providers/multi_backend_remote_provider.dart';
import 'package:bat_track_v1/models/services/remote/remote_storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/unified_entity_service.dart';
import '../../core/services/unified_entity_service_impl.dart';
import '../../data/core/unified_model.dart';
import '../../data/local/models/adapters/hive_entity_factory.dart';
import '../data/hive_model.dart';
import 'logged_entity_service.dart';

typedef FromJson<T> = T Function(Map<String, dynamic> json);

// Provider pour un service synchronisé avec logs (LoggedEntitySyncService)
Provider<SafeAndLoggedEntityService<M, E>> buildLoggedEntitySyncServiceProvider<
  M extends UnifiedModel,
  E extends HiveModel<M>
>({required String collectionName, required HiveEntityFactory<M, E> factory}) {
  return Provider<SafeAndLoggedEntityService<M, E>>((ref) {
    // On crée le service de base (Hybride Sync)
    final baseService = UnifiedEntityServiceImpl<M, E>(
      collectionName: collectionName,
      factory: factory,
      remoteStorage: ref.watch(multiBackendRemoteProvider),
    );

    return SafeAndLoggedEntityService<M, E>(baseService, ref);
  });
}

// Provider pour un service local avec logs (LoggedEntityService) (sans sync)
Provider<SafeAndLoggedEntityService<M, E>> buildLoggedEntityServiceProvider<
  M extends UnifiedModel,
  E extends HiveModel<M>
>({required String boxName, required HiveEntityFactory<M, E> factory}) {
  return Provider<SafeAndLoggedEntityService<M, E>>((ref) {
    final remoteStorageService = ref.watch(multiBackendRemoteProvider);
    final hiveService = EntityServiceFactory.instance.createSyncedService(
      collectionName: boxName,
      factory: factory,
      remoteStorageService: remoteStorageService,
    );
    return SafeAndLoggedEntityService(hiveService, ref);
  });
}

// Provider pour les services (sans logs et sync)
UnifiedEntityService<M, E>
buildEntityServiceProvider<M extends UnifiedModel, E extends HiveModel<M>>({
  required String collectionOrBoxName,
  required HiveEntityFactory<M, E> factory,
  RemoteStorageService? remoteStorageService,
}) {
  return UnifiedEntityServiceImpl<M, E>(
    factory: factory,
    collectionName: collectionOrBoxName,
    remoteStorage: remoteStorageService!,
  );
}
