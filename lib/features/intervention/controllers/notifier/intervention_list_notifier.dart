import 'package:bat_track_v1/data/local/models/index_model_extention.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/entity_providers.dart';
import '../../../../core/riverpod/base_list_notifier.dart';

class InterventionListNotifier extends BaseListNotifier<Intervention> {
  @override
  Future<List<Intervention>> fetchAll() =>
      ref.read(interventionServiceProvider).getAll();

  @override
  Future<void> save(Intervention item) =>
      ref.read(interventionServiceProvider).save(item);

  @override
  Future<void> delete(String id) =>
      ref.read(interventionServiceProvider).delete(id);

  @override
  Future<void> addItem(Intervention item) =>
      ref.read(interventionServiceProvider).save(item);
}

final interventionListProvider =
    AsyncNotifierProvider<InterventionListNotifier, List<Intervention>>(
      () => InterventionListNotifier(),
    );
