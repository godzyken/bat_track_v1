import 'package:shared_models/shared_models.dart';

import '../../services/logged_entity_service.dart';
import '../hive_model.dart';

abstract class BaseRepository<M extends UnifiedModel, E extends HiveModel<M>> {
  /// Le service qui gère déjà la sécurité, les logs, Hive et le Multi-Remote
  final SafeAndLoggedEntityService<M, E> service;

  const BaseRepository(this.service);

  // 🔍 READ - Utilise la méthode hybride (Local avec fallback Remote)
  Future<M?> getById(String id) => service.get(id);

  // 📜 READ ALL - Utilise la méthode hybride
  Future<List<M>> getAll() => service.getAll();

  // 📡 WATCH - Le flux fusionné Local + Remote
  Stream<List<M>> watchAll() => service.watchAll();

  // 💾 SAVE - Sauvegarde synchronisée (Hive + Cloud)
  Future<void> save(M data) => service.save(data);

  // 🗑 DELETE - Suppression synchronisée
  Future<void> delete(String id) => service.delete(id);

  // 🔄 SYNC - Forcer la synchronisation depuis le serveur
  Future<void> refreshFromServer() => service.syncAllFromRemote();

  /// Récupère des données filtrées (Remote)
  Future<List<M>> getFiltered({
    required dynamic Function(dynamic query) queryBuilder,
  }) async {
    // On délègue au service qui gère le Multi-Backend
    return await service.getRemoteFiltered(queryBuilder: queryBuilder);
  }

  /// Écoute des données filtrées (Remote)
  Stream<List<M>> watchFiltered({
    required dynamic Function(dynamic query) queryBuilder,
  }) {
    return service.watchRemoteFiltered(queryBuilder: queryBuilder);
  }
}
