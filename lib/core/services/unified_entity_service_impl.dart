import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_models/shared_models.dart';

import '../../core/services/unified_entity_service.dart';
import '../../data/local/models/adapters/hive_entity_factory.dart';
import '../../data/remote/providers/multi_backend_remote_provider.dart';
import '../../models/data/hive_model.dart';

/// Classe concrète légère pour permettre l'instanciation du service abstrait
class UnifiedEntityServiceImpl<M extends UnifiedModel, E extends HiveModel<M>>
    extends UnifiedEntityService<M, E> {
  UnifiedEntityServiceImpl({
    required super.collectionName,
    required super.factory,
    required super.remoteStorage,
  });

  @override
  Future<List<M>> getAll() async {
    await startRemoteSync();
    try {
      // 2. On récupère les données distantes (Raw JSON)
      final raws = await remoteStorage.getAllRaw(collectionName);
      // 3. Conversion via la factory (Remote JSON -> Model)
      final remoteModels = raws
          .map((json) => factory.fromRemote(json))
          .toList();
      // 4. Synchronisation : On met à jour le cache local Hive
      for (final model in remoteModels) {
        await saveLocal(model);
      }
      return remoteModels;
    } catch (e) {
      return await getAllLocal();
    }
  }
}

/// Provider générique pour tout service synchronisé (Local + Remote)
Provider<UnifiedEntityService<M, E>> syncedEntityProvider<
  M extends UnifiedModel,
  E extends HiveModel<M>
>({required String collectionName, required HiveEntityFactory<M, E> factory}) {
  return Provider<UnifiedEntityService<M, E>>((ref) {
    final remoteStorage = ref.watch(multiBackendRemoteProvider);

    return UnifiedEntityServiceImpl<M, E>(
      collectionName: collectionName,
      factory: factory,
      remoteStorage: remoteStorage,
    );
  });
}
