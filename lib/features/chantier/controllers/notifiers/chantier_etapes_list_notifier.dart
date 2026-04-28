import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/entity_providers.dart';
import '../../../../core/riverpod/base_list_notifier.dart';
import '../../../../data/local/models/index_model_extention.dart';

class ChantierEtapesListNotifier extends BaseListNotifier<ChantierEtape> {
  @override
  Future<List<ChantierEtape>> fetchAll() =>
      ref.read(chantierEtapeServiceProvider).getAll();

  @override
  Future<void> save(ChantierEtape item) =>
      ref.read(chantierEtapeServiceProvider).save(item);

  @override
  Future<void> delete(String id) =>
      ref.read(chantierEtapeServiceProvider).delete(id);

  @override
  Future<void> addItem(ChantierEtape item) =>
      ref.read(chantierEtapeServiceProvider).save(item);
}

final chantierEtapesListProvider =
    AsyncNotifierProvider<ChantierEtapesListNotifier, List<ChantierEtape>>(
      () => ChantierEtapesListNotifier(),
    );
