import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/models/index_model_extention.dart';
import '../../../data/local/providers/hive_provider.dart';

final allProjectsFutureProvider = FutureProvider<List<Projet>>((ref) async {
  return await ref.read(allProjectsProvider);
});

final allChantiersFutureProvider = FutureProvider<List<Chantier>>((ref) async {
  return await ref.read(allChantiersProvider);
});

final allInterventionsFutureProvider = FutureProvider<List<Intervention>>((
  ref,
) async {
  return await ref.read(allInterventionsProvider);
});
