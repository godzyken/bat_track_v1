import 'package:async/async.dart';
import 'package:collection/collection.dart';
import 'package:hive_ce/hive.dart';
import 'package:shared_models/shared_models.dart';

import '../../data/local/models/adapters/hive_entity_factory.dart';
import '../../models/data/hive_model.dart';
import '../../models/services/remote/remote_storage_service.dart';

/// Interface de base pour tous les services
abstract class BaseEntityService<M extends UnifiedModel> {
  Future<M?> get(String id);
  Future<void> save(M model);
  Future<void> delete(String id);
  Stream<List<M>> watchAll();
  Future<List<M>> getAll();
}

/// Service unifié remplaçant EntityService, EntityServices,
/// EntitySyncService et SyncedEntityService
abstract class UnifiedEntityService<
  M extends UnifiedModel,
  E extends HiveModel<M>
>
    implements BaseEntityService<M> {
  final String collectionName;
  final HiveEntityFactory<M, E> factory;
  final RemoteStorageService remoteStorage;

  late final Box<E> _localBox;
  bool _isInitialized = false;

  UnifiedEntityService({
    required this.collectionName,
    required this.factory,
    required this.remoteStorage,
  });

  // ═══════════════════════════════════════════════════════════════
  // INITIALISATION
  // ═══════════════════════════════════════════════════════════════

  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;

    if (!Hive.isBoxOpen(collectionName)) {
      _localBox = await Hive.openBox<E>(collectionName);
    } else {
      _localBox = Hive.box<E>(collectionName);
    }

    _isInitialized = true;
  }

  // ═══════════════════════════════════════════════════════════════
  // OPÉRATIONS LOCALES (HIVE)
  // ═══════════════════════════════════════════════════════════════

  Future<void> saveLocal(M model) async {
    await _ensureInitialized();
    final entity = factory.toEntity(model);
    await _localBox.put(entity.id, entity);
  }

  Future<M?> getLocal(String id) async {
    await _ensureInitialized();
    final json = _localBox.get(id);
    return json != null ? factory.fromEntity(json) : null;
  }

  Future<List<M>> getAllLocal() async {
    await _ensureInitialized();
    return factory.fromEntities(_localBox.values.toList());
  }

  Future<void> deleteLocal(String id) async {
    await _ensureInitialized();
    await _localBox.delete(id);
  }

  Stream<List<M>> watchLocal() {
    return _localBox.watch().map(
      (_) => factory.fromEntities(_localBox.values.toList()),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // OPÉRATIONS DISTANTES (FIRESTORE/SUPABASE)
  // ═══════════════════════════════════════════════════════════════

  Future<void> saveRemote(M entity) async {
    await remoteStorage.saveRaw(collectionName, entity.id, entity.toJson());
  }

  Future<M?> getRemote(String id) async {
    final json = await remoteStorage.getRaw(collectionName, id);
    return json.isEmpty ? null : factory.fromRemote(json);
  }

  Future<List<M>> getAllRemote() async {
    final raws = await remoteStorage.getAllRaw(collectionName);
    return raws.map((json) => factory.fromRemote(json)).toList();
  }

  Future<void> deleteRemote(String id) async {
    await remoteStorage.deleteRaw(collectionName, id);
  }

  Stream<List<M>> watchRemote() {
    return remoteStorage
        .watchCollectionRaw(collectionName)
        .map((raws) => raws.map((json) => factory.fromRemote(json)).toList());
  }

  // ═══════════════════════════════════════════════════════════════
  // SYNCHRONISATION
  // ═══════════════════════════════════════════════════════════════

  /// Synchronise une entité (local → remote)
  Future<void> sync(M entity) async {
    await saveLocal(entity);
    await saveRemote(entity);
  }

  /// Synchronise toutes les entités locales vers le remote
  Future<void> syncAllToRemote() async {
    final localItems = await getAllLocal();
    for (final item in localItems) {
      await saveRemote(item);
    }
  }

  /// Récupère toutes les entités du remote et met à jour le local
  Future<void> syncAllFromRemote() async {
    final remoteItems = await getAllRemote();
    for (final item in remoteItems) {
      await saveLocal(item);
    }
  }

  /// Stream combiné (merge local + remote)
  @override
  Stream<List<M>> watchAll() async* {
    await _ensureInitialized();

    final localStream = watchLocal();
    final remoteStream = watchRemote();

    await for (final _ in StreamGroup.merge([localStream, remoteStream])) {
      // Merge strategy: priorité au plus récent (updatedAt)
      final local = await getAllLocal();
      final remote = await getAllRemote();

      final merged = <String, M>{};

      // Ajoute local d'abord
      for (final item in local) {
        merged[item.id] = item;
      }

      // Override avec remote si plus récent
      for (final item in remote) {
        final existing = merged[item.id];
        if (existing == null ||
            (item.updatedAt != null &&
                existing.updatedAt != null &&
                item.updatedAt!.isAfter(existing.updatedAt!))) {
          merged[item.id] = item;
        }
      }

      yield merged.values.toList();
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // OPÉRATIONS HYBRIDES
  // ═══════════════════════════════════════════════════════════════

  /// Récupère depuis local, fallback sur remote
  @override
  Future<M?> get(String id) async {
    var entity = await getLocal(id);
    if (entity == null) {
      entity = await getRemote(id);
      if (entity != null) {
        await saveLocal(entity);
      }
    }
    return entity;
  }

  /// Sauvegarde + sync automatique
  @override
  Future<void> save(M entity) async {
    await sync(entity);
  }

  /// Suppression locale + remote
  @override
  Future<void> delete(String id) async {
    await deleteLocal(id);
    await deleteRemote(id);
  }

  /// Vérifie l'existence (local d'abord)
  Future<bool> exists(String id) async {
    final local = await getLocal(id);
    return local != null;
  }

  // ═══════════════════════════════════════════════════════════════
  // UTILITAIRES
  // ═══════════════════════════════════════════════════════════════

  Future<void> clear() async {
    await _ensureInitialized();
    await _localBox.clear();
  }

  Future<void> close() async {
    if (_isInitialized) {
      await _localBox.close();
      _isInitialized = false;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // RECHERCHE ET FILTRAGE (REMOTE)
  // ═══════════════════════════════════════════════════════════════

  /// Récupère une liste filtrée depuis le remote
  Future<List<M>> getRemoteFiltered({
    required dynamic Function(dynamic query) queryBuilder,
  }) async {
    // 1. On récupère les raws depuis le storage (ex: Firestore)
    final _ = await remoteStorage.getAllRaw(
      collectionName,
      // On pourrait passer une extension de getAllRaw ou utiliser watchCollectionRaw
    );

    final filteredRaws = await remoteStorage
        .watchCollectionRaw(collectionName, queryBuilder: queryBuilder)
        .first;

    return filteredRaws.map((json) => factory.fromRemote(json)).toList();
  }

  /// Stream distant filtré
  Stream<List<M>> watchRemoteFiltered({
    required dynamic Function(dynamic query) queryBuilder,
  }) {
    return remoteStorage
        .watchCollectionRaw(collectionName, queryBuilder: queryBuilder)
        .map((raws) => raws.map((json) => factory.fromRemote(json)).toList());
  }

  /// Stream combiné pour une seule entité (local + remote)
  Stream<M?> watch(String id) {
    // Lit les deux streams de listes et filtre par ID
    return watchAll().map(
      (list) => list.firstWhereOrNull((item) => item.id == id),
    );
  }
}
