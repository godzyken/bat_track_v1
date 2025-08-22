import 'dart:developer' as developer;

import 'package:async/async.dart';
import 'package:bat_track_v1/models/services/remote/remote_storage_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/widgets.dart';

import '../../data/local/models/base/has_files.dart';
import '../../data/local/models/documents/pieces_jointes.dart';
import '../../data/local/services/hive_service.dart';
import '../../data/local/services/service_type.dart';
import '../../data/remote/services/storage_service.dart';
import '../data/json_model.dart';
import 'entity_sync_services.dart';

class SyncedEntityService<T extends JsonModel> implements EntityServices<T> {
  static final _cacheTimestamps = <String, DateTime>{};
  static const Duration ttl = Duration(seconds: 60);

  final EntityLocalService<T> local;
  final EntityRemoteService<T> remote;

  SyncedEntityService(this.local, this.remote);

  @override
  Future<void> save(T item, [String? id]) async {
    final docId = id ?? item.id;
    await Future.wait([local.put(docId, item), remote.save(item, docId)]);
    if (item is HasFile) await _handleFileUpload(item as HasFile, docId);
  }

  Future<void> _handleFileUpload(HasFile item, String docId) async {
    try {
      final file = item.getFile();
      final fileName = file.path.split('/').last;
      final path = '${T.toString()}/$docId/$fileName';
      await StorageService(FirebaseStorage.instance).uploadFile(file, path);
      developer.log('📁 Fichier uploadé: $path');
    } catch (e) {
      developer.log('❌ Erreur upload fichier: $e');
    }
  }

  @override
  Future<void> delete(String id) async {
    await local.delete(id);
    await remote.delete(id);
  }

  @override
  Future<List<T>> getAll() async {
    final now = DateTime.now();
    final lastFetch = _cacheTimestamps[T.toString()];
    if (lastFetch != null && now.difference(lastFetch) < ttl) {
      developer.log('⛔ [SyncedEntity:$T] getAll ignored (TTL)');
      return local.getAll();
    }
    _cacheTimestamps[T.toString()] = now;
    developer.log('⏳ [SyncedEntity:$T] getAll started');

    final modelsFromCloud = await remote.getAll();
    for (final model in modelsFromCloud) {
      await local.put(model.id, model);
    }
    developer.log('✅ [SyncedEntity:$T] getAll done');
    return modelsFromCloud;
  }

  Future<List<T>> getAllFromLocal() => local.getAll();
  Future<T?> getByIdFromLocal(String id) => local.get(id);

  Future<T?> getByIdFromRemote(String id) async {
    final remoteItem = await remote.getById(id);
    if (remoteItem != null) await local.put(id, remoteItem);
    return remoteItem;
  }

  Future<void> syncFromRemote({BuildContext? context}) async {
    final remoteItems = await remote.getAll();
    for (final item in remoteItems) {
      await local.put(item.id, item);
      if ((item is HasFile || item is PieceJointe) &&
          context?.mounted == true) {
        await HiveService.precachePieceJointe<T>(context!, T.toString(), item);
      }
    }
  }

  Future<void> syncToRemote() async {
    final localItems = await local.getAll();
    for (final item in localItems) {
      await remote.save(item, item.id);
    }
  }

  Future<void> precacheAllWithContext(BuildContext context) async {
    final items = await local.getAll();
    for (final item in items) {
      if (item is PieceJointe && context.mounted) {
        await HiveService.precachePieceJointe<PieceJointe>(
          context,
          T.toString(),
          item,
        );
      }
    }
  }

  Stream<List<T>> watchAllCombined() async* {
    final hiveStream = local.watchAll();
    final remoteStream = remote.watchAll();

    await for (final event in StreamGroup.merge([hiveStream, remoteStream])) {
      final Map<String, T> mergedMap = {};
      final localItems = await local.getAll();
      for (final item in localItems) {
        mergedMap[item.id] = item;
      }

      for (final item in event) {
        final existing = mergedMap[item.id];
        if (existing == null ||
            (item.updatedAt != null &&
                (existing.updatedAt == null ||
                    item.updatedAt!.isBefore(item.updatedAt!)))) {
          mergedMap[item.id] = item;
        }
      }

      yield mergedMap.values.toList();
    }
  }

  @override
  Future<void> clear() async {
    // TODO: implement clear
    throw UnimplementedError();
  }

  @override
  Future<void> closeAll() {
    // TODO: implement closeAll
    throw UnimplementedError();
  }

  @override
  Future<void> deleteAll() {
    // TODO: implement deleteAll
    throw UnimplementedError();
  }

  @override
  Future<void> deleteByQuery(Map<String, dynamic> query) {
    // TODO: implement deleteByQuery
    throw UnimplementedError();
  }

  @override
  Future<bool> exists(String id) {
    // TODO: implement exists
    throw UnimplementedError();
  }

  @override
  Future<T?> get(String id) async {
    final localEntity = await local.get(id);
    if (localEntity != null) return localEntity;

    final remoteEntity = await remote.getById(id);
    if (remoteEntity != null) {
      await local.put(remoteEntity.id, remoteEntity);
    }
    return remoteEntity;
  }

  @override
  Future<T?> getById(String id) {
    // TODO: implement getById
    throw UnimplementedError();
  }

  @override
  Future<List<T>> getByQuery(Map<String, dynamic> query) {
    // TODO: implement getByQuery
    throw UnimplementedError();
  }

  @override
  Future<List<String>> getKeys() {
    // TODO: implement getKeys
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> getLocalRaw(String id) {
    // TODO: implement getLocalRaw
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> getRemoteRaw(String id) {
    // TODO: implement getRemoteRaw
    throw UnimplementedError();
  }

  @override
  Future<void> init() {
    // TODO: implement init
    throw UnimplementedError();
  }

  @override
  Future<void> open() {
    // TODO: implement open
    throw UnimplementedError();
  }

  @override
  Future<List<T>> query(String query) {
    // TODO: implement query
    throw UnimplementedError();
  }

  @override
  Future<void> saveLocalRaw(String id, Map<String, dynamic> data) {
    // TODO: implement saveLocalRaw
    throw UnimplementedError();
  }

  @override
  Future<void> saveRemoteRaw(String id, Map<String, dynamic> data) {
    // TODO: implement saveRemoteRaw
    throw UnimplementedError();
  }

  @override
  Future<List<T>> sortedBy(
    Comparable Function(T p1) selector, {
    bool descending = false,
  }) {
    // TODO: implement sortedBy
    throw UnimplementedError();
  }

  @override
  Future<void> update(T entity, String id) {
    // TODO: implement update
    throw UnimplementedError();
  }

  @override
  Stream<List<T>> watchAll() => watchAllCombined();

  @override
  Stream<List<T>> watchByChantier(String chantierId) {
    // TODO: implement watchByChantier
    throw UnimplementedError();
  }

  @override
  Stream<List<T>> watchByQuery(Map<String, dynamic> query) {
    // TODO: implement watchByQuery
    throw UnimplementedError();
  }

  @override
  Future<List<T>> where(bool Function(T p1) test) {
    // TODO: implement where
    throw UnimplementedError();
  }

  @override
  // TODO: implement boxName
  String get boxName => throw UnimplementedError();

  @override
  Future<void> deleteRawRemote(String id) {
    // TODO: implement deleteRawRemote
    throw UnimplementedError();
  }

  @override
  Future<List<T>> fetchAll({T Function(Map<String, dynamic> p1)? fromJson}) {
    // TODO: implement fetchAll
    throw UnimplementedError();
  }

  @override
  // TODO: implement fromJson
  T Function(Map<String, dynamic> p1) get fromJson =>
      throw UnimplementedError();

  @override
  Future<List<T>> getAllRawRemote({DateTime? updatedAfter, int? limit}) {
    // TODO: implement getAllRawRemote
    throw UnimplementedError();
  }

  @override
  Future<T?> getRawRemote(String id) {
    // TODO: implement getRawRemote
    throw UnimplementedError();
  }

  @override
  Future<void> put(String id, T item) async {
    await local.put(id, item);
    await remote.save(item, id);
  }

  @override
  // TODO: implement remoteStorageService
  RemoteStorageService get remoteStorageService => throw UnimplementedError();

  @override
  Future<void> remove(String id) {
    // TODO: implement remove
    throw UnimplementedError();
  }

  @override
  Future<void> saveRawRemote(T entity) {
    // TODO: implement saveRawRemote
    throw UnimplementedError();
  }

  @override
  // TODO: implement storage
  StorageService get storage => throw UnimplementedError();

  @override
  // TODO: implement storageMode
  StorageMode get storageMode => throw UnimplementedError();

  @override
  Stream<List<T>> watchAllRawRemote({Function(dynamic query)? queryBuilder}) {
    // TODO: implement watchAllRawRemote
    throw UnimplementedError();
  }

  @override
  Future<List<Map<String, dynamic>>> getAllRaw(
    String collectionOrTable, {
    DateTime? updatedAfter,
    int? limit,
  }) {
    // TODO: implement getAllRaw
    throw UnimplementedError();
  }
}
