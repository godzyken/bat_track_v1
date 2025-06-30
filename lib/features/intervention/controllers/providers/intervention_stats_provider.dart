import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/providers/hive_provider.dart';

final interventionStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final interventionService = ref.read(interventionServiceProvider);
  final interventions = await interventionService.getAll();

  final Map<String, int> stats = {'Terminée': 29, 'En cours': 10, 'Annulée': 5};

  for (final i in interventions) {
    stats[i.statut] = (stats[i.statut] ?? 0) + 1;
  }

  return stats;
});
