import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/local/providers/hive_provider.dart';
import '../data/json_model.dart';
import '../services/entity_service.dart';

abstract class EntityListNotifier<T extends JsonModel>
    extends AsyncNotifier<List<T>> {
  late final EntityService<T> service;

  @override
  Future<List<T>> build() async {
    service = ref.read(entityServiceProvider<T>());
    return service.getAll();
  }

  Future<void> add(T entity) async {
    // 🔐 Vérification de l'id
    final isIdEmpty = entity.id.isEmpty;
    final id = isIdEmpty ? const Uuid().v4() : entity.id;

    // 🧬 Création d'une entité avec id corrigé si nécessaire
    final safeEntity = isIdEmpty ? entity.copyWithId(id) : entity;

    final alreadyExists = await service.exists(id);
    if (alreadyExists) {
      await service.update(safeEntity, id);
    } else {
      await service.save(safeEntity, id);
    }

    state = AsyncValue.data(await service.getAll());
  }

  Future<void> save(T entity) async {
    await service.save(entity, entity.id);
    state = AsyncValue.data(await service.getAll());
  }

  Future<void> updateEntity(T entity) async {
    await service.update(entity, entity.id);
    state = AsyncValue.data(await service.getAll());
  }

  Future<void> delete(String id) async {
    await service.delete(id);
    state = AsyncValue.data(await service.getAll());
  }
}
