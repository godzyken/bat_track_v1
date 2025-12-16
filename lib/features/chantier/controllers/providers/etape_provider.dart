import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/models/index_model_extention.dart';
import '../../../../data/remote/providers/chantier_provider.dart';

final etapeProvider = Provider.family<ChantierEtape?, String>((ref, etapeId) {
  final chantierAsync = ref.watch(
    chantierAdvancedNotifierProvider('chantierId'),
  );

  final chantier = chantierAsync.value;
  return chantier?.etapes.firstWhereOrNull((e) => e.id == etapeId);
});

enum EtapeStatut { aFaire, enCours, terminee }

EtapeStatut getEtapeStatut(ChantierEtape e) {
  if (e.terminee == true) return EtapeStatut.terminee;
  if (e.dateDebut.isBefore(DateTime.now())) {
    return EtapeStatut.enCours;
  }
  return EtapeStatut.aFaire;
}

final etapesParStatutProvider = Provider.family<
  AsyncValue<Map<EtapeStatut, List<ChantierEtape>>>,
  String
>((ref, chantierId) {
  final chantierAsync = ref.watch(chantierAdvancedNotifierProvider(chantierId));

  return chantierAsync.when(
    loading: () => const AsyncValue.loading(),
    error: (err, stack) => AsyncValue.error(err, stack),
    data: (chantier) {
      if (chantier == null) {
        return const AsyncValue.data({
          EtapeStatut.aFaire: [],
          EtapeStatut.enCours: [],
          EtapeStatut.terminee: [],
        });
      }

      // On utilise les étapes chargées dans le Chantier
      final etapes = chantier.etapes;

      final grouped = <EtapeStatut, List<ChantierEtape>>{
        EtapeStatut.aFaire: [],
        EtapeStatut.enCours: [],
        EtapeStatut.terminee: [],
      };

      for (final e in etapes) {
        grouped[getEtapeStatut(e)]!.add(e);
      }

      return AsyncValue.data(grouped);
    },
  );
});
