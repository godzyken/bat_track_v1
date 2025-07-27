import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/models/index_model_extention.dart';
import '../../../chantier/controllers/providers/chantier_sync_provider.dart';

final techniciensStreamProvider = StreamProvider<List<Technicien>>((ref) {
  final service = ref.watch(techSyncServiceProvider);
  return service.watchAll();
});

final techniciensFutureProvider = FutureProvider<List<Technicien>>((ref) async {
  final service = ref.watch(techSyncServiceProvider);
  return await service.getAll();
});
