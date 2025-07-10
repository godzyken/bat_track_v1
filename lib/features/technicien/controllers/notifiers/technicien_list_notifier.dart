import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/models/index_model_extention.dart';
import '../../../../data/local/services/hive_service.dart';

final techniciensListProvider =
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

  Future<void> updateTechnicien(Technicien updated) async {
    final existing = await HiveService.get<Technicien>(
      'techniciens',
      updated.id,
    );
    if (existing == updated) return; // pas de changement
    await HiveService.put('techniciens', updated.id, updated);
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

  Future<void> assignToChantierOrEtape({
    required String technicienId,
    String? chantierId,
    String? etapeId,
  }) async {
    final list = await HiveService.getAll<Technicien>('techniciens');
    final index = list.indexWhere((t) => t.id == technicienId);
    if (index == -1) return;

    final technicien = list[index];

    final updated = Technicien(
      id: technicien.id,
      nom: technicien.nom,
      email: technicien.email,
      competences: technicien.competences,
      specialite: technicien.specialite,
      tauxHoraire: technicien.tauxHoraire,
      disponible: technicien.disponible,
      localisation: technicien.localisation,
      chantiersAffectes: [
        ...technicien.chantiersAffectes,
        if (chantierId != null &&
            !technicien.chantiersAffectes.contains(chantierId))
          chantierId,
      ],
      etapesAffectees: [
        ...technicien.etapesAffectees,
        if (etapeId != null && !technicien.etapesAffectees.contains(etapeId))
          etapeId,
      ],
    );

    await HiveService.put('techniciens', updated.id, updated);
    state = AsyncValue.data(
      await HiveService.getAll<Technicien>('techniciens'),
    );
  }

  Future<void> unassignFromChantierOrEtape({
    required String technicienId,
    String? chantierId,
    String? etapeId,
  }) async {
    final list = await HiveService.getAll<Technicien>('techniciens');
    final index = list.indexWhere((t) => t.id == technicienId);
    if (index == -1) return;

    final technicien = list[index];

    final updated = Technicien(
      id: technicien.id,
      nom: technicien.nom,
      email: technicien.email,
      competences: technicien.competences,
      specialite: technicien.specialite,
      tauxHoraire: technicien.tauxHoraire,
      disponible: technicien.disponible,
      localisation: technicien.localisation,
      chantiersAffectes: [...technicien.chantiersAffectes..remove(chantierId)],
      etapesAffectees: [...technicien.etapesAffectees..remove(etapeId)],
    );

    await HiveService.put('techniciens', updated.id, updated);
    state = AsyncValue.data(
      await HiveService.getAll<Technicien>('techniciens'),
    );
  }
}
