import 'package:async/async.dart';
import 'package:collection/collection.dart';
import 'package:hive/hive.dart';

import '../../data/core/unified_model.dart';
import '../../models/services/remote/remote_storage_service.dart';

/// Service unifié remplaçant EntityService, EntityServices,
/// EntitySyncService et SyncedEntityService
class UnifiedEntityService<T extends UnifiedModel> {
  final String collectionName;
  final T Function(Map<String, dynamic>) fromJson;
  final RemoteStorageService remoteStorage;

  late final Box<Map> _localBox;
  bool _isInitialized = false;

  UnifiedEntityService({
    required this.collectionName,
    required this.fromJson,
    required this.remoteStorage,
  });

  // ═══════════════════════════════════════════════════════════════
  // INITIALISATION
  // ═══════════════════════════════════════════════════════════════

  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;

    if (!Hive.isBoxOpen(collectionName)) {
      _localBox = await Hive.openBox<Map>(collectionName);
    } else {
      _localBox = Hive.box<Map>(collectionName);
    }

    _isInitialized = true;
  }

  // ═══════════════════════════════════════════════════════════════
  // OPÉRATIONS LOCALES (HIVE)
  // ═══════════════════════════════════════════════════════════════

  Future<void> saveLocal(T entity) async {
    await _ensureInitialized();
    await _localBox.put(entity.id, entity.toJson());
  }

  Future<T?> getLocal(String id) async {
    await _ensureInitialized();
    final json = _localBox.get(id);
    return json != null ? fromJson(Map<String, dynamic>.from(json)) : null;
  }

  Future<List<T>> getAllLocal() async {
    await _ensureInitialized();
    return _localBox.values
        .map((json) => fromJson(Map<String, dynamic>.from(json)))
        .toList();
  }

  Future<void> deleteLocal(String id) async {
    await _ensureInitialized();
    await _localBox.delete(id);
  }

  Stream<List<T>> watchLocal() {
    return _localBox.watch().map(
      (_) =>
          _localBox.values
              .map((json) => fromJson(Map<String, dynamic>.from(json)))
              .toList(),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // OPÉRATIONS DISTANTES (FIRESTORE/SUPABASE)
  // ═══════════════════════════════════════════════════════════════

  Future<void> saveRemote(T entity) async {
    await remoteStorage.saveRaw(collectionName, entity.id, entity.toJson());
  }

  Future<T?> getRemote(String id) async {
    final json = await remoteStorage.getRaw(collectionName, id);
    return json.isEmpty ? null : fromJson(json);
  }

  Future<List<T>> getAllRemote() async {
    final raws = await remoteStorage.getAllRaw(collectionName);
    return raws.map(fromJson).toList();
  }

  Future<void> deleteRemote(String id) async {
    await remoteStorage.deleteRaw(collectionName, id);
  }

  Stream<List<T>> watchRemote() {
    return remoteStorage
        .watchCollectionRaw(collectionName)
        .map((raws) => raws.map(fromJson).toList());
  }

  // ═══════════════════════════════════════════════════════════════
  // SYNCHRONISATION
  // ═══════════════════════════════════════════════════════════════

  /// Synchronise une entité (local → remote)
  Future<void> sync(T entity) async {
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
  Stream<List<T>> watchAll() async* {
    final localStream = watchLocal();
    final remoteStream = watchRemote();

    await for (final _ in StreamGroup.merge([localStream, remoteStream])) {
      // Merge strategy: priorité au plus récent (updatedAt)
      final local = await getAllLocal();
      final remote = await getAllRemote();

      final merged = <String, T>{};

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
  Future<T?> get(String id) async {
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
  Future<void> save(T entity) async {
    await sync(entity);
  }

  /// Suppression locale + remote
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

  /// Stream combiné pour une seule entité (local + remote)
  Stream<T?> watch(String id) {
    // Lit les deux streams de listes et filtre par ID
    return watchAll().map(
      (list) => list.firstWhereOrNull((item) => item.id == id),
    );
  }
}
