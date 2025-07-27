import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/models/index_model_extention.dart';
import '../../../../data/local/providers/hive_provider.dart';

final etapeProvider = Provider.family<ChantierEtape?, String>((ref, etapeId) {
  final chantier = ref.watch(chantierNotifierProvider('chantierId'));
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

final etapesParStatutProvider = FutureProvider.family<
  Map<EtapeStatut, List<ChantierEtape>>,
  String
>((ref, chantierId) async {
  final box = await ref.watch(chantierEtapeBoxProvider);
  final etapes = box.values.where((e) => e.chantierId == chantierId).toList();

  final grouped = <EtapeStatut, List<ChantierEtape>>{
    EtapeStatut.aFaire: [],
    EtapeStatut.enCours: [],
    EtapeStatut.terminee: [],
  };

  for (final e in etapes) {
    grouped[getEtapeStatut(e)]!.add(e);
  }

  return grouped;
});
