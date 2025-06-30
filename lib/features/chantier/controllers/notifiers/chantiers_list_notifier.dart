import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/models/chantier.dart';
import '../../../../data/local/providers/hive_provider.dart';

class ChantierListNotifier extends AsyncNotifier<List<Chantier>> {
  @override
  Future<List<Chantier>> build() async {
    final service = ref.read(chantierServiceProvider);
    return service.getAll();
  }

  Future<void> add(Chantier chantier) async {
    final service = ref.read(chantierServiceProvider);
    await service.add(chantier, chantier.id);
    state = AsyncValue.data(await service.getAll());
  }

  Future<void> save(Chantier chantier) async {
    final service = ref.read(chantierServiceProvider);
    await service.save(chantier, chantier.id);
    state = AsyncValue.data(await service.getAll());
  }

  Future<void> updateChantier(Chantier chantier) async {
    final service = ref.read(chantierServiceProvider);
    await service.update(chantier, chantier.id);
    state = AsyncValue.data(await service.getAll());
  }

  Future<void> deleteChantier(String id) async {
    final service = ref.read(chantierServiceProvider);
    await service.delete(id);
    state = AsyncValue.data(await service.getAll());
  }
}

final chantierListProvider =
    AsyncNotifierProvider<ChantierListNotifier, List<Chantier>>(
      () => ChantierListNotifier(),
    );
