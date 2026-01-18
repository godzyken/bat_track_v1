import 'package:bat_track_v1/models/services/remote/remote_storage_service.dart';

import '../../core/services/unified_entity_service.dart';
import '../../data/core/unified_model.dart';

class CloudflareEntityService<M extends UnifiedModel>
    implements BaseEntityService<M> {
  final String collectionName;
  final M Function(Map<String, dynamic>) fromJson;
  final RemoteStorageService remoteStorage;

  CloudflareEntityService({
    required this.collectionName,
    required this.fromJson,
    required this.remoteStorage,
  });

  @override
  Future<void> save(M model) async {
    await remoteStorage.saveRaw(collectionName, model.id, model.toJson());
  }

  Future<void> update(M item, String id) async => save(item);

  @override
  Future<void> delete(String id) async {
    await remoteStorage.deleteRaw(collectionName, id);
  }

  @override
  Future<List<M>> getAll() async {
    final raws = await remoteStorage.getAllRaw(collectionName);
    return raws.map(fromJson).toList();
  }

  @override
  Future<M?> get(String id) async {
    final raw = await remoteStorage.getRaw(collectionName, id);
    if (raw.isEmpty) return null;
    return fromJson(raw);
  }

  Future<M?> getById(String id) async => get(id);

  Future<bool> exists(String id) async {
    final raw = await remoteStorage.getRaw(collectionName, id);
    return raw.isNotEmpty;
  }

  Future<List<String>> getKeys() async {
    final raws = await remoteStorage.getAllRaw(collectionName);
    return raws.map((r) => r['id'] as String).toList();
  }

  Future<void> deleteAll() async {
    final keys = await getKeys();
    for (final id in keys) {
      await delete(id);
    }
  }

  Future<void> clear() async => deleteAll();

  Future<List<M>> where(bool Function(M) test) async {
    final all = await getAll();
    return all.where(test).toList();
  }

  Future<List<M>> sortedBy(
    Comparable Function(M) selector, {
    bool descending = false,
  }) async {
    final list = await getAll();
    list.sort(
      (a, b) => selector(a).compareTo(selector(b)) * (descending ? -1 : 1),
    );
    return list;
  }

  Future<List<M>> query(String query) async {
    final all = await getAll();
    return all.where((e) => e.toString().contains(query)).toList();
  }

  Future<void> deleteByQuery(Map<String, dynamic> queryStr) async {
    if (queryStr.isEmpty) return;

    final list = await getByQuery(queryStr);
    for (final item in list) {
      await delete(item.id);
    }
  }

  Future<List<M>> getByQuery(Map<String, dynamic> query) async {
    final all = await getAll();
    return all.where((item) {
      final json = item.toJson();
      return query.entries.every((entry) => json[entry.key] == entry.value);
    }).toList();
  }

  Stream<List<M>> watchByChantier(String chantierId) {
    return remoteStorage
        .watchCollectionRaw(
          collectionName,
          queryBuilder: (q) => q.where('chantierId', isEqualTo: chantierId),
        )
        .map(
          (items) => items
              .map((it) => fromJson(Map<String, dynamic>.from(it)))
              .toList(),
        );
  }

  @override
  Stream<List<M>> watchAll() {
    return remoteStorage
        .watchCollectionRaw(collectionName)
        .map(
          (list) => list
              .map((json) => fromJson(Map<String, dynamic>.from(json)))
              .toList(),
        );
  }
}
