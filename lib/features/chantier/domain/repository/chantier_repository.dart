import 'package:bat_track_v1/models/data/repository/base_repository.dart';

import '../../../../data/local/models/entities/chantier_entity.dart';
import '../../../../data/local/models/index_model_extention.dart';

class ChantierRepository extends BaseRepository<Chantier, ChantierEntity> {
  ChantierRepository(super.service);

  Future<List<Chantier>> getChantiersEnCours() async {
    final all = await getAll();
    return all.where((c) => c.etat == 'en_cours').toList();
  }

  Future<List<Chantier>> getForTechnicien(String userId) {
    return getFiltered(
      queryBuilder: (query) =>
          query.where('techniciens', arrayContains: userId),
    );
  }

  Future<List<Chantier>> getForClient(String userId) {
    return getFiltered(
      queryBuilder: (query) => query.where('clientId', isEqualTo: userId),
    );
  }

  Stream<List<Chantier>> watchForClient(String userId) {
    return watchFiltered(
      queryBuilder: (query) => query.where('clientId', isEqualTo: userId),
    );
  }
}
