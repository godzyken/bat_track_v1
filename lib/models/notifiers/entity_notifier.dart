import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../data/core/unified_model.dart';
import '../services/entity_service.dart';

class EntityNotifier<T extends UnifiedModel> extends StateNotifier<T?> {
  final String id;
  final Box<T> box;
  final EntityService<T> service;

  EntityNotifier({required this.id, required this.box, required this.service})
    : super(box.get(id)) {
    _listenRemote();
  }

  void _listenRemote() {
    service.getById(id).then((entity) {
      if (entity != null) {
        box.put(id, entity);
        state = entity;
      }
    });
  }

  /// Met à jour l'entité localement + Firestore + Hive
  Future<void> update(T updated) async {
    await service.update(updated, updated.id);
    box.put(updated.id, updated);
    state = updated;
  }

  /// Supprime l'entité (optionnel)
  Future<void> delete() async {
    if (state == null) return;
    await service.delete(id);
    box.delete(id);
    state = null;
  }
}
