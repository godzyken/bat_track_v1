import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/models/index_model_extention.dart';
import '../../../../data/local/services/hive_service.dart';

final techniciensProvider =
    AsyncNotifierProvider<TechniciensNotifier, List<Technicien>>(
      TechniciensNotifier.new,
    );

class TechniciensNotifier extends AsyncNotifier<List<Technicien>> {
  @override
  Future<List<Technicien>> build() async {
    return HiveService.getAll<Technicien>('techniciens');
  }

  Future<void> addMock() async {
    final item = Technicien.mock();
    await HiveService.put('techniciens', item.id, item);
    state = AsyncValue.data(
      await HiveService.getAll<Technicien>('techniciens'),
    );
  }

  Future<void> delete(String id) async {
    await HiveService.delete<Technicien>('techniciens', id);
    state = AsyncValue.data(
      await HiveService.getAll<Technicien>('techniciens'),
    );
  }
}
