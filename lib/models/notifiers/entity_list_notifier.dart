import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/services/unified_entity_service.dart';
import '../../data/core/unified_model.dart';
import '../data/hive_model.dart';

abstract class EntityListNotifier<
  M extends UnifiedModel,
  E extends HiveModel<M>
>
    extends AsyncNotifier<List<M>> {
  late final UnifiedEntityService<M, E> service;

  @override
  Future<List<M>> build() async {
    // service = ref.read(entityServiceProvider<T>());

    return service.watchAll().first;
  }

  Future<void> add(M entity) async {
    // 🔐 Vérification de l'id
    final isIdEmpty = entity.id.isEmpty;
    final id = isIdEmpty ? const Uuid().v4() : entity.id;

    // 🧬 Création d'une entité avec id corrigé si nécessaire
    final safeEntity = isIdEmpty ? (entity.copyWithId(id) as M) : entity;

    final alreadyExists = await service.exists(id);
    if (alreadyExists) {
      await service.save(safeEntity);
    } else {
      await service.save(safeEntity);
    }

    state = AsyncValue.data(await service.getAllRemote());
  }

  Future<void> save(M entity) async {
    await service.save(entity);
    state = AsyncValue.data(await service.getAllRemote());
  }

  Future<void> updateEntity(M entity) async {
    await service.save(entity);
    state = AsyncValue.data(await service.getAllRemote());
  }

  Future<void> delete(String id) async {
    await service.delete(id);
    state = AsyncValue.data(await service.getAllRemote());
  }
}
