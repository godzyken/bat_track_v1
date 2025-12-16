import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/models/index_model_extention.dart';
import '../../../data/local/providers/hive_provider.dart';

final allProjectsFutureProvider = FutureProvider<List<Projet>>((ref) async {
  return await ref.read(allProjectsProvider.future);
});

final allChantiersFutureProvider = FutureProvider<List<Chantier>>((ref) async {
  return await ref.read(allChantiersStreamProvider.future);
});

final allInterventionsFutureProvider = FutureProvider<List<Intervention>>((
  ref,
) async {
  return await ref.read(allInterventionsStreamProvider.future);
});
