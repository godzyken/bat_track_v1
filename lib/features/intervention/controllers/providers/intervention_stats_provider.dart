import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_models/shared_models.dart';

import '../../../../data/local/providers/hive_provider.dart';

final interventionStatsProvider =
    FutureProvider<Map<String, Map<String, Map<String, int>>>>((ref) async {
      final interventionService = ref.read(interventionServiceProvider);
      final interventions = await interventionService.getAll();

      // Groupement par chantier (on utilise chantierId comme clé de projet)
      final byProjet = groupBy(interventions, (i) => i.chantierId);

      return byProjet.map((projetId, chantierList) {
        final byChantier = groupBy(chantierList, (i) => i.chantierId);

        final chantierStats = byChantier.map((chantierId, interventions) {
          // 'statut' n'existe plus — on dérive de 'terminee'
          final byStatut = groupBy(
            interventions,
            (i) => i.terminee ? 'Terminée' : 'En cours',
          );
          final statutCounts = byStatut.map<String, int>(
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

      final chantierId = params['chantierId']!;
      final statut = params['statut']!;

      final interventions = await interventionService.getAll();
      // Filtre par chantierId + statut dérivé de 'terminee'
      return interventions
          .where(
            (i) =>
                i.chantierId == chantierId &&
                (i.terminee ? 'Terminée' : 'En cours') == statut,
          )
          .toList();
    });
