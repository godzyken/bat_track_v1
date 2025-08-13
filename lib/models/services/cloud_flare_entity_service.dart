import '../../../models/data/json_model.dart';
import '../../data/remote/services/cloud_flare_service.dart';
import 'entity_service.dart';

class CloudflareEntityService<T extends JsonModel> implements EntityService<T> {
  final String collectionName;
  final T Function(Map<String, dynamic>) fromJson;

  const CloudflareEntityService({
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
  Future<void> update(T item, String id) async {
    await CloudFlareService.instance.saveRaw(collectionName, id, item.toJson());
  }

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
  Future<void> open() async {
    // Firestore/Cloudflare n'a pas besoin d'ouverture explicite
    return;
  }

  @override
  Future<void> init() async {
    // Pas d'init nécessaire ici
    return;
  }

  @override
  Future<void> closeAll() async {
    // Pas de fermeture explicite
    return;
  }

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
    final fieldName = queryStr.keys.first;
    final value = queryStr.values.first;

    final list = await getAll();
    for (final item in list) {
      final json = item.toJson();
      if (json[fieldName] == value) {
        await delete(item.id);
      }
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

  @override
  Future<Map<String, dynamic>> getLocalRaw(String id) {
    throw UnsupportedError(
      'getLocalRaw n’est pas supporté pour StorageMode.cloudflare',
    );
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
    throw UnsupportedError(
      'saveLocalRaw n’est pas supporté pour StorageMode.cloudflare',
    );
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
}
