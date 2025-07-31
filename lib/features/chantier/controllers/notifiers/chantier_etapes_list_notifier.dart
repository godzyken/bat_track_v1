import 'package:bat_track_v1/models/notifiers/entity_list_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/models/index_model_extention.dart';

class ChantierEtapesListNotifier extends EntityListNotifier<ChantierEtape> {}

/*AsyncNotifier<List<ChantierEtape>> {
  @override
  Future<List<ChantierEtape>> build() async {
    final service = ref.read(chantierEtapeServiceProvider);
    return service.getAll();
  }

  Future<void> add(ChantierEtape etape) async {
    final service = ref.read(chantierEtapeServiceProvider);
    await service.add(etape, etape.id);
    state = AsyncValue.data(await service.getAll());
  }

  Future<void> save(ChantierEtape etape) async {
    final service = ref.read(chantierEtapeServiceProvider);
    await service.save(etape, etape.id);
    state = AsyncValue.data(await service.getAll());
  }

  Future<void> updateChantier(ChantierEtape etape) async {
    final service = ref.read(chantierEtapeServiceProvider);
    await service.update(etape, etape.id);
    state = AsyncValue.data(await service.getAll());
  }

  Future<void> deleteChantier(String id) async {
    final service = ref.read(chantierEtapeServiceProvider);
    await service.delete(id);
    state = AsyncValue.data(await service.getAll());
  }
}*/

final chantierEtapesListProvider =
    AsyncNotifierProvider<ChantierEtapesListNotifier, List<ChantierEtape>>(
      () => ChantierEtapesListNotifier(),
    );
