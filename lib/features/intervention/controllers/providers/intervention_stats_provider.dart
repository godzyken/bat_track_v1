import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/models/index_model_extention.dart';
import '../../../../providers/hive_firebase_provider.dart';

final interventionStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final hive = ref.read(hiveServiceProvider);
  final box = await hive.getBox<Intervention>('interventions');
  final interventions = box.values;

  final Map<String, int> stats = {'Terminée': 33, 'En cours': 15, 'Annulée': 3};

  for (final i in interventions) {
    stats[i.statut] = (stats[i.statut] ?? 0) + 1;
  }

  return stats;
});
