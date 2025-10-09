import 'package:bat_track_v1/models/notifiers/entity_list_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/models/index_model_extention.dart';
import '../../../../data/local/providers/hive_provider.dart';
import '../../../../data/local/services/hive_service.dart';

final techniciensListProvider =
    AsyncNotifierProvider<TechniciensNotifier, List<Technicien>>(
      TechniciensNotifier.new,
    );

class TechniciensNotifier extends EntityListNotifier<Technicien> {
  @override
  Future<List<Technicien>> build() async {
    final service = ref.read(technicienServiceProvider);
    return service.getAll();
  }

  Future<void> addMock() async {
    final item = Technicien.mock();
    await HiveService.put('techniciens', item.id, item);
    state = AsyncValue.data(
      await HiveService.getAll<Technicien>('techniciens'),
    );
  }

  Future<void> updateTechnicien(Technicien updated) async {
    final service = ref.read(technicienServiceProvider);
    await service.update(updated, updated.id);
    state = AsyncValue.data(await service.getAll());
  }

  @override
  Future<void> delete(String id) async {
    final service = ref.read(technicienServiceProvider);
    await service.delete(id);
    state = AsyncValue.data(await service.getAll());
  }

  Future<void> assignToChantierOrEtape({
    required String technicienId,
    String? chantierId,
    String? etapeId,
  }) async {
    final service = ref.read(technicienServiceProvider);

    final list = await service.getAll();
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
      chantiersAffectees: [
        ...technicien.chantiersAffectees,
        if (chantierId != null &&
            !technicien.chantiersAffectees.contains(chantierId))
          chantierId,
      ],
      etapesAffectees: [
        ...technicien.etapesAffectees,
        if (etapeId != null && !technicien.etapesAffectees.contains(etapeId))
          etapeId,
      ],
      createdAt: technicien.createdAt,
      updatedAt: technicien.updatedAt,
    );

    await service.update(updated, updated.id);
    state = AsyncValue.data(await service.getAll());
  }

  Future<void> unassignFromChantierOrEtape({
    required String technicienId,
    String? chantierId,
    String? etapeId,
  }) async {
    final service = ref.read(technicienServiceProvider);

    final list = await service.getAll();
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
      chantiersAffectees: [
        ...technicien.chantiersAffectees..remove(chantierId),
      ],
      etapesAffectees: [...technicien.etapesAffectees..remove(etapeId)],
      updatedAt: technicien.updatedAt,
      createdAt: technicien.createdAt,
    );

    await service.update(updated, updated.id);
    state = AsyncValue.data(await service.getAll());
  }
}

/*{
  @override
  Future<List<Technicien>> build() async {
    final service = ref.read(technicienServiceProvider);
    return service.getAll();
  }

  Future<void> addMock() async {
    final item = Technicien.mock();
    await HiveService.put('techniciens', item.id, item);
    state = AsyncValue.data(
      await HiveService.getAll<Technicien>('techniciens'),
    );
  }

  Future<void> updateTechnicien(Technicien updated) async {
    final service = ref.read(technicienServiceProvider);
    await service.update(updated, updated.id);
    state = AsyncValue.data(await service.getAll());
  }

  Future<void> delete(String id) async {
    final service = ref.read(technicienServiceProvider);
    await service.delete(id);
    state = AsyncValue.data(await service.getAll());
  }

  Future<void> assignToChantierOrEtape({
    required String technicienId,
    String? chantierId,
    String? etapeId,
  }) async {
    final service = ref.read(technicienServiceProvider);

    final list = await service.getAll();
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
      chantiersAffectees: [
        ...technicien.chantiersAffectees,
        if (chantierId != null &&
            !technicien.chantiersAffectees.contains(chantierId))
          chantierId,
      ],
      etapesAffectees: [
        ...technicien.etapesAffectees,
        if (etapeId != null && !technicien.etapesAffectees.contains(etapeId))
          etapeId,
      ],
      updatedAt: technicien.updatedAt,
    );

    await service.update(updated, updated.id);
    state = AsyncValue.data(await service.getAll());
  }

  Future<void> unassignFromChantierOrEtape({
    required String technicienId,
    String? chantierId,
    String? etapeId,
  }) async {
    final service = ref.read(technicienServiceProvider);

    final list = await service.getAll();
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
      chantiersAffectees: [
        ...technicien.chantiersAffectees..remove(chantierId),
      ],
      etapesAffectees: [...technicien.etapesAffectees..remove(etapeId)],
      updatedAt: technicien.updatedAt,
    );

    await service.update(updated, updated.id);
    state = AsyncValue.data(await service.getAll());
  }
}*/
