import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/models/chantiers/intervention.dart';
import '../../../../data/local/providers/hive_provider.dart';

final interventionStatsProvider =
    FutureProvider<Map<String, Map<String, Map<String, int>>>>((ref) async {
      final interventionService = ref.read(interventionServiceProvider);
      final interventions = await interventionService.getAll();

      // Groupement par projet
      final byProjet = groupBy(interventions, (i) => i.id);

      return byProjet.map((projetId, chantierList) {
        final byChantier = groupBy(chantierList, (i) => i.chantierId);

        final chantierStats = byChantier.map((chantierId, interventions) {
          final byStatut = groupBy(interventions, (i) => i.statut);
          final statutCounts = byStatut.map(
            (statut, list) => MapEntry(statut, list.length),
          );

          return MapEntry(chantierId, statutCounts);
        });

        return MapEntry(projetId, chantierStats);
      });
    });

final interventionsByStatutProvider =
    FutureProvider.family<List<Intervention>, Map<String, String>>((
      ref,
      params,
    ) async {
      final interventionService = ref.read(interventionServiceProvider);

      final chantierId = params["chantierId"]!;
      final statut = params["statut"]!;

      final interventions = await interventionService.getAll();
      return interventions
          .where((i) => i.chantierId == chantierId && i.statut == statut)
          .toList();
    });
