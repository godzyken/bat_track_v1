import 'package:shared_models/shared_models.dart';

import '../../services/multi_backend_remote_service.dart';
import '../../services/remote/remote_storage_service.dart';

class HiveRemoteStorageWrapper<T extends UnifiedModel>
    extends RemoteStorageService {
  final MultiBackendRemoteService multiBackend;

  HiveRemoteStorageWrapper({required this.multiBackend});

  @override
  Future<Map<String, dynamic>> getRaw(
    String collectionOrTable,
    String id,
  ) async {
    final item = await multiBackend.getRaw(collectionOrTable, id);
    if (item.isEmpty) {
      throw Exception('Item not found in remote backends: $id');
    }
    return item;
  }

  @override
  Future<void> saveRaw(
    String collectionOrTable,
    String id,
    Map<String, dynamic> data,
  ) async {
    await multiBackend.saveRaw(collectionOrTable, id, data);
  }

  @override
  Future<void> deleteRaw(String collectionOrTable, String id) async {
    await multiBackend.deleteRaw(collectionOrTable, id);
  }

  @override
  Future<List<Map<String, dynamic>>> getAllRaw(
    String collectionOrTable, {
    DateTime? updatedAfter,
    int? limit,
  }) async {
    final listT = await multiBackend.getAllRaw(
      collectionOrTable,
      updatedAfter: updatedAfter,
      limit: limit,
    );
    return listT.map((t) => t).toList();
  }

  @override
  Stream<List<Map<String, dynamic>>> watchCollectionRaw(
    String collectionOrTable, {
    dynamic Function(dynamic query)? queryBuilder,
  }) {
    return multiBackend
        .watchCollectionRaw(collectionOrTable, queryBuilder: queryBuilder)
        .map((listT) => listT.map((t) => t).toList());
  }

  Future<bool> fileExists(String path) {
    // TODO: implémenter selon le backend choisi
    throw UnimplementedError();
  }
}
