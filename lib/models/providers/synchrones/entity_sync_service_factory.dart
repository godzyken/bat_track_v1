import 'package:bat_track_v1/models/services/remote/remote_storage_service.dart';

import '../../../data/core/unified_model.dart';
import '../../../data/local/services/service_type.dart';
import '../../services/entity_sync_services.dart';
import '../../services/hive_entity_service.dart';
import '../../services/remote/remote_entity_service_adapter.dart';

class EntitySyncServiceFactory {
  EntitySyncServiceFactory._(); // constructeur privé

  static final EntitySyncServiceFactory instance = EntitySyncServiceFactory._();

  /// Crée un service de synchronisation local + distant
  EntitySyncService<T> create<T extends UnifiedModel>(
    StorageMode mode, {
    required String collectionName,
    required T Function(Map<String, dynamic>) fromJson,
    required String? supabaseTable,
    RemoteStorageService? remote,
  }) {
    // Service local : toujours Hive
    final localService = HiveEntityService<T>(
      boxName: collectionName,
      fromJson: fromJson,
    );

    final remoteService = RemoteEntityServiceAdapter<T>(
      fromJson: fromJson,
      collection: supabaseTable!,
      storage: remote!,
    );

    // Service distant : selon mode
    switch (mode) {
      case StorageMode.hive:
        // Mode uniquement local → on sync local avec local (pas de remote)
        return EntitySyncService<T>(localService, remoteService);

      case StorageMode.firebase:
        return EntitySyncService<T>(localService, remoteService);

      case StorageMode.firestore:
        return EntitySyncService<T>(localService, remoteService);

      case StorageMode.cloudflare:
        return EntitySyncService<T>(localService, remoteService);
    }
  }
}
