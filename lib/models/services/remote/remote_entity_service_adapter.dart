import 'package:shared_models/shared_models.dart';

import '../entity_sync_services.dart';
import 'remote_storage_service.dart';

class RemoteEntityServiceAdapter<T extends UnifiedModel>
    implements EntityRemoteService<T> {
  final RemoteStorageService storage;
  final String collection;
  final T Function(Map<String, dynamic>) fromJson;

  RemoteEntityServiceAdapter({
    required this.storage,
    required this.collection,
    required this.fromJson,
  });

  @override
  Future<void> save(T item, String id) async {
    await storage.saveRaw(collection, id, item.toJson());
  }

  @override
  Future<T?> getById(String id) async {
    final json = await storage.getRaw(collection, id);
    if (json.isEmpty) return null;
    return fromJson(json);
  }

  @override
  Future<List<T>> getAll() async {
    final raws = await storage.getAllRaw(collection);
    return raws.map(fromJson).toList();
  }

  @override
  Future<void> delete(String id) async {
    await storage.deleteRaw(collection, id);
  }

  @override
  Stream<List<T>> watchAll() {
    return storage
        .watchCollectionRaw(collection)
        .map((rows) => rows.map(fromJson).toList());
  }

  @override
  Future fileExists(String path) {
    // TODO: implement fileExists
    throw UnimplementedError();
  }
}
