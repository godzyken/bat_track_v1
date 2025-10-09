import '../../../data/core/unified_model.dart';
import '../../data/json_model.dart';
import '../../services/multi_backend_remote_service.dart';
import '../../services/remote/remote_storage_service.dart';

class HiveRemoteStorageWrapper<T extends UnifiedModel>
    extends RemoteStorageService {
  final MultiBackendRemoteService<T> multiBackend;

  HiveRemoteStorageWrapper({required this.multiBackend});

  @override
  Future<Map<String, dynamic>> getRaw(
    String collectionOrTable,
    String id,
  ) async {
    final item = await multiBackend.getById(id);
    if (item == null) {
      throw Exception('Item not found in remote backends: $id');
    }
    return item.toJson();
  }

  @override
  Future<void> saveRaw(
    String collectionOrTable,
    String id,
    Map<String, dynamic> data,
  ) async {
    final item = JsonModelFactory.fromDynamicOrThrow<T>(data);
    await multiBackend.save(item, id);
  }

  @override
  Future<void> deleteRaw(String collectionOrTable, String id) async {
    await multiBackend.delete(id);
  }

  @override
  Future<List<Map<String, dynamic>>> getAllRaw(
    String collectionOrTable, {
    DateTime? updatedAfter,
    int? limit,
  }) async {
    final listT = await multiBackend.getAll();
    return listT.map((t) => t.toJson()).toList();
  }

  @override
  Stream<List<Map<String, dynamic>>> watchCollectionRaw(
    String collectionOrTable, {
    dynamic Function(dynamic query)? queryBuilder,
  }) {
    return multiBackend.watchAll().map(
      (listT) => listT.map((t) => t.toJson()).toList(),
    );
  }

  Future<bool> fileExists(String path) {
    // TODO: implémenter selon le backend choisi
    throw UnimplementedError();
  }
}
