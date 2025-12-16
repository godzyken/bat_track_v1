import 'package:bat_track_v1/models/services/remote/remote_storage_service.dart';

import '../../core/services/unified_entity_service.dart';
import '../../data/core/unified_model.dart';
import '../../data/remote/services/cloud_flare_service.dart';

class CloudflareEntityService<T extends UnifiedModel>
    implements UnifiedEntityService<T> {
  final String collectionName;
  final T Function(Map<String, dynamic>) fromJson;

  @override
  final RemoteStorageService remoteStorage = CloudFlareService.instance;

  CloudflareEntityService({
    required this.collectionName,
    required this.fromJson,
  });

  @override
  Future<void> save(T item, [String? id]) async {
    await CloudFlareService.instance.saveRaw(
      collectionName,
      id ?? item.id,
      item.toJson(),
    );
  }

  @override
  Future<void> update(T item, String id) async => save(item, id);

  @override
  Future<void> delete(String id) async {
    await CloudFlareService.instance.deleteRaw(collectionName, id);
  }

  @override
  Future<List<T>> getAll() async {
    final raws = await CloudFlareService.instance.getAllRaw(collectionName);
    return raws.map(fromJson).toList();
  }

  @override
  Future<T?> get(String id) async {
    final raw = await CloudFlareService.instance.getRaw(collectionName, id);
    if (raw.isEmpty) return null;
    return fromJson(raw);
  }

  @override
  Future<T?> getById(String id) async => get(id);

  @override
  Future<bool> exists(String id) async {
    final raw = await CloudFlareService.instance.getRaw(collectionName, id);
    return raw.isNotEmpty;
  }

  @override
  Future<List<String>> getKeys() async {
    final raws = await CloudFlareService.instance.getAllRaw(collectionName);
    return raws.map((r) => r['id'] as String).toList();
  }

  @override
  Future<void> deleteAll() async {
    final keys = await getKeys();
    for (final id in keys) {
      await delete(id);
    }
  }

  @override
  Future<void> clear() async => deleteAll();

  @override
  Future<List<T>> where(bool Function(T) test) async {
    final all = await getAll();
    return all.where(test).toList();
  }

  @override
  Future<List<T>> sortedBy(
    Comparable Function(T) selector, {
    bool descending = false,
  }) async {
    final list = await getAll();
    list.sort(
      (a, b) => selector(a).compareTo(selector(b)) * (descending ? -1 : 1),
    );
    return list;
  }

  @override
  Future<List<T>> query(String query) async {
    final all = await getAll();
    return all.where((e) => e.toString().contains(query)).toList();
  }

  @override
  Future<void> deleteByQuery(Map<String, dynamic> queryStr) async {
    if (queryStr.isEmpty) return;

    final list = await getByQuery(queryStr);
    for (final item in list) {
      await delete(item.id);
    }
  }

  @override
  Stream<List<T>> watchByChantier(String chantierId) {
    return CloudFlareService.instance
        .watchCollectionRaw(
          collectionName,
          queryBuilder: (q) => q.where('chantierId', isEqualTo: chantierId),
        )
        .map(
          (items) =>
              items
                  .map((it) => fromJson(Map<String, dynamic>.from(it)))
                  .toList(),
        );
  }

  static const _unsupportedLocal =
      'Non supporté : ce service est purement Cloudflare (Cloud-Only).';

  @override
  Future<Map<String, dynamic>> getLocalRaw(String id) {
    throw UnsupportedError(_unsupportedLocal);
  }

  @override
  Future<Map<String, dynamic>> getRemoteRaw(String id) {
    return CloudFlareService.instance.getRaw(collectionName, id);
  }

  @override
  Future<void> saveRemoteRaw(String id, Map<String, dynamic> data) {
    return CloudFlareService.instance.saveRaw(collectionName, id, data);
  }

  @override
  Future<void> saveLocalRaw(String id, Map<String, dynamic> data) {
    throw UnsupportedError(_unsupportedLocal);
  }

  @override
  Future<List<T>> getByQuery(Map<String, dynamic> query) {
    // TODO: implement getByQuery
    throw UnimplementedError();
  }

  @override
  Stream<List<T>> watchAll() {
    // TODO: implement watchAll
    throw UnimplementedError();
  }

  @override
  Stream<List<T>> watchByQuery(Map<String, dynamic> query) {
    // TODO: implement watchByQuery
    throw UnimplementedError();
  }

  @override
  Future<void> close() {
    // TODO: implement close
    throw UnimplementedError();
  }

  @override
  Future<void> deleteLocal(String id) {
    // TODO: implement deleteLocal
    throw UnimplementedError();
  }

  @override
  Future<void> deleteRemote(String id) {
    // TODO: implement deleteRemote
    throw UnimplementedError();
  }

  @override
  Future<List<T>> getAllLocal() {
    // TODO: implement getAllLocal
    throw UnimplementedError();
  }

  @override
  Future<List<T>> getAllRemote() {
    // TODO: implement getAllRemote
    throw UnimplementedError();
  }

  @override
  Future<T?> getLocal(String id) {
    // TODO: implement getLocal
    throw UnimplementedError();
  }

  @override
  Future<T?> getRemote(String id) {
    // TODO: implement getRemote
    throw UnimplementedError();
  }

  @override
  Future<void> saveLocal(T entity) {
    // TODO: implement saveLocal
    throw UnimplementedError();
  }

  @override
  Future<void> saveRemote(T entity) {
    // TODO: implement saveRemote
    throw UnimplementedError();
  }

  @override
  Future<void> sync(T entity) {
    // TODO: implement sync
    throw UnimplementedError();
  }

  @override
  Future<void> syncAllFromRemote() {
    // TODO: implement syncAllFromRemote
    throw UnimplementedError();
  }

  @override
  Future<void> syncAllToRemote() {
    // TODO: implement syncAllToRemote
    throw UnimplementedError();
  }

  @override
  Stream<T?> watch(String id) {
    // TODO: implement watch
    throw UnimplementedError();
  }

  @override
  Stream<List<T>> watchLocal() {
    // TODO: implement watchLocal
    throw UnimplementedError();
  }

  @override
  Stream<List<T>> watchRemote() {
    // TODO: implement watchRemote
    throw UnimplementedError();
  }
}
