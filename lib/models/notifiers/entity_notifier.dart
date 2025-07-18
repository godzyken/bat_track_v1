import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../data/local/services/service_type.dart';
import '../data/json_model.dart';

class EntityNotifier<T extends JsonModel> extends StateNotifier<T?> {
  final String id;
  final Box<T> box;
  final EntityServices<T> service;

  EntityNotifier({required this.id, required this.box, required this.service})
    : super(box.get(id));

  /// Met à jour l'entité localement + Firestore + Hive
  Future<void> update(T updated) async {
    await service.update(updated, updated.id!);
    await box.put(id, updated);
    state = updated;
  }

  /// Supprime l'entité (optionnel)
  Future<void> delete() async {
    if (state == null) return;
    await service.delete(id);
    await box.delete(id);
    state = null;
  }
}
