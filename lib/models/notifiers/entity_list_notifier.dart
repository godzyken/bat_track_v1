import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    if (await service.exists(entity.id) == false) {
      await service.save(entity, entity.id);
    } else {
      await service.update(entity, entity.id);
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
