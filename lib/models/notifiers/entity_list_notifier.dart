import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/services/unified_entity_service.dart';
import '../../data/core/unified_model.dart';

abstract class EntityListNotifier<T extends UnifiedModel>
    extends AsyncNotifier<List<T>> {
  late final UnifiedEntityService<T> service;

  @override
  Future<List<T>> build() async {
    // service = ref.read(entityServiceProvider<T>());

    return service.watchAll().first;
  }

  Future<void> add(T entity) async {
    // 🔐 Vérification de l'id
    final isIdEmpty = entity.id.isEmpty;
    final id = isIdEmpty ? const Uuid().v4() : entity.id;

    // 🧬 Création d'une entité avec id corrigé si nécessaire
    final safeEntity = isIdEmpty ? (entity.copyWithId(id) as T) : entity;

    final alreadyExists = await service.exists(id);
    if (alreadyExists) {
      await service.save(safeEntity);
    } else {
      await service.save(safeEntity);
    }

    state = AsyncValue.data(await service.getAllRemote());
  }

  Future<void> save(T entity) async {
    await service.save(entity);
    state = AsyncValue.data(await service.getAllRemote());
  }

  Future<void> updateEntity(T entity) async {
    await service.save(entity);
    state = AsyncValue.data(await service.getAllRemote());
  }

  Future<void> delete(String id) async {
    await service.delete(id);
    state = AsyncValue.data(await service.getAllRemote());
  }
}
