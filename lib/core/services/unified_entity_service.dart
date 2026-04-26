import 'dart:async';

import 'package:collection/collection.dart';
import 'package:hive_ce/hive.dart';
import 'package:shared_models/shared_models.dart';

import '../../data/local/models/adapters/hive_entity_factory.dart';
import '../../models/data/hive_model.dart';
import '../../models/services/remote/remote_storage_service.dart';
import '../config/debounce.dart';

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

  StreamSubscription? _remoteSub;

  late final FrameSyncQueue<M> _syncQueue;

  UnifiedEntityService({
    required this.collectionName,
    required this.factory,
    required this.remoteStorage,
  }) {
    _syncQueue = FrameSyncQueue<M>(
      onBatch: (batch) async {
        for (final item in batch) {
          await saveRemote(item);
        }
      },
    );
  }

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

  Future<void> startRemoteSync() async {
    await _ensureInitialized();

    _remoteSub?.cancel();

    _remoteSub = watchRemote().listen((remoteItems) async {
      final localMap = {for (final item in await getAllLocal()) item.id: item};

      for (final remote in remoteItems) {
        final local = localMap[remote.id];

        final shouldUpdate =
            local == null ||
            (remote.updatedAt != null &&
                local.updatedAt != null &&
                remote.updatedAt!.isAfter(local.updatedAt!));

        if (shouldUpdate) {
          await _localBox.put(remote.id, factory.toEntity(remote));
        }
      }
    });
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

  Stream<List<M>> watchLocal() async* {
    await _ensureInitialized();
    yield factory.fromEntities(_localBox.values.toList()); // 👈 initial
    yield* _localBox.watch().map(
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

    final initialLocal = await getAllLocal();
    yield initialLocal;

    yield* _localBox.watch().map(
      (_) => factory.fromEntities(_localBox.values.toList()),
    );
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

  /// Récupère depuis remote, fallback sur local
  @override
  Future<List<M>> getAll() async {
    // 1. On s'assure que Hive est prêt
    await _ensureInitialized();

    try {
      // 2. On récupère les données distantes (Raw JSON)
      final raws = await remoteStorage.getAllRaw(collectionName);

      // 3. Conversion via la factory (Remote JSON -> Model)
      final remoteModels = raws
          .map((json) => factory.fromRemote(json))
          .toList();

      // 4. Synchronisation : On met à jour le cache local Hive
      for (final model in remoteModels) {
        await saveLocal(model);
      }

      return remoteModels;
    } catch (e) {
      // 5. Fallback : Si le réseau échoue, on renvoie les données locales
      return await getAllLocal();
    }
  }

  /// Sauvegarde + sync automatique
  @override
  Future<void> save(M entity) async {
    await saveLocal(entity);
    _syncQueue.add(entity);
  }

  /// Suppression locale + remote
  @override
  Future<void> delete(String id) async {
    final existing = await getLocal(id);

    if (existing == null) return;

    final deleted = markDeleted(existing);

    await saveLocal(deleted);
    _syncQueue.add(deleted);
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

  Future<void> bidirectionalSync() async {
    final localData = await getAllLocal();
    final remoteData = await getAllRemote();
    final mergedData = <M>[];
    final conflictMap = <String, M>{};
    final conflictIds = <String>{};
    final conflictIdsLocal = <String>{};
    final conflictIdsRemote = <String>{};
    final conflictIdsBoth = <String>{};
    final conflictIdsLocalOnly = <String>{};
    final conflictIdsRemoteOnly = <String>{};
    final conflictIdsBothOnly = <String>{};
    final conflictIdsLocalUpdated = <String>{};
    final conflictIdsRemoteUpdated = <String>{};
    final conflictIdsBothUpdated = <String>{};
    final conflictIdsLocalOnlyUpdated = <String>{};
    final conflictIdsRemoteOnlyUpdated = <String>{};
    final conflictIdsBothOnlyUpdated = <String>{};
    final conflictIdsLocalOnlyDeleted = <String>{};
    final conflictIdsRemoteOnlyDeleted = <String>{};
    final conflictIdsBothOnlyDeleted = <String>{};

    for (final localItem in localData) {
      final remoteItem = remoteData.firstWhereOrNull(
        (item) => item.id == localItem.id,
      );

      if (remoteItem == null) {
        conflictIdsLocal.add(localItem.id);
        conflictIdsLocalOnly.add(localItem.id);
        conflictIdsLocalOnlyDeleted.add(localItem.id);
      } else if (localItem.updatedAt!.isAfter(remoteItem.updatedAt!)) {
        conflictIdsLocal.add(localItem.id);
        conflictIdsLocalUpdated.add(localItem.id);
        conflictIdsLocalOnlyUpdated.add(localItem.id);
        conflictIdsBoth.add(localItem.id);
        conflictIdsBothUpdated.add(localItem.id);
        mergedData.add(localItem);
        conflictMap[localItem.id] = localItem;
      } else {
        conflictIdsRemote.add(remoteItem.id);
        conflictIdsRemoteUpdated.add(remoteItem.id);
        conflictIdsRemoteOnlyUpdated.add(remoteItem.id);
        conflictIdsBoth.add(remoteItem.id);
        conflictIdsBothUpdated.add(remoteItem.id);
        mergedData.add(remoteItem);
        conflictMap[remoteItem.id] = remoteItem;
      }

      conflictIdsBothOnly.add(localItem.id);
      conflictIdsBothOnlyUpdated.add(localItem.id);
      conflictIdsBothOnlyDeleted.add(localItem.id);
    }

    for (final remoteItem in remoteData) {
      final localItem = localData.firstWhereOrNull(
        (item) => item.id == remoteItem.id,
      );

      if (localItem == null) {
        conflictIdsRemote.add(remoteItem.id);
        conflictIdsRemoteOnly.add(remoteItem.id);
        conflictIdsRemoteOnlyDeleted.add(remoteItem.id);
      } else if (remoteItem.updatedAt!.isAfter(localItem.updatedAt!)) {
        conflictIdsRemote.add(remoteItem.id);
        conflictIdsRemoteUpdated.add(remoteItem.id);
        conflictIdsRemoteOnlyUpdated.add(remoteItem.id);
        conflictIdsBoth.add(remoteItem.id);
        conflictIdsBothUpdated.add(remoteItem.id);

        mergedData.add(remoteItem);
        conflictMap[remoteItem.id] = remoteItem;
      }
    }

    for (final conflictId in conflictIdsLocal) {
      final conflictItem = conflictMap[conflictId];
      if (conflictItem != null) {
        await update(conflictItem);
      }
    }

    for (final conflictId in conflictIdsRemote) {
      final conflictItem = conflictMap[conflictId];
      if (conflictItem != null) {
        await update(conflictItem);
      }
    }

    await saveBatch(mergedData);
  }

  Future<void> update(M entity) async {
    await saveLocal(entity);
    await saveRemote(entity);
  }

  Future<void> saveBatch(List<M> entities) async {
    for (final entity in entities) {
      await save(entity);
    }
  }

  M markDeleted(M entity) {
    final now = DateTime.now();
    return entity.markDeleted(now) as M;
  }
}
