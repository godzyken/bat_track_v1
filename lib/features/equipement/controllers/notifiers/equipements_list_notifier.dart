import 'package:bat_track_v1/data/local/models/chantiers/equipement.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/riverpod/base_list_notifier.dart';
import '../../../../data/local/providers/hive_provider.dart';

class EquipementListNotifier extends BaseListNotifier<Equipement> {
  @override
  Future<List<Equipement>> fetchAll() =>
      ref.read(equipementServiceProvider).getAll();

  @override
  Future<void> save(Equipement item) =>
      ref.read(equipementServiceProvider).save(item);

  @override
  Future<void> delete(String id) =>
      ref.read(equipementServiceProvider).delete(id);

  @override
  Future<void> addItem(Equipement item) =>
      ref.read(equipementServiceProvider).save(item);
}

final equipementListProvider =
    AsyncNotifierProvider<EquipementListNotifier, List<Equipement>>(
      () => EquipementListNotifier(),
    );
