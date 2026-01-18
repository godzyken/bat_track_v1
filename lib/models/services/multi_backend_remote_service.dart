import 'package:bat_track_v1/data/local/services/service_type.dart';
import 'package:bat_track_v1/models/services/remote/remote_storage_service.dart';

class MultiBackendRemoteService extends RemoteStorageService {
  final List<StorageMode> enabledBackends;
  final Map<StorageMode, RemoteStorageService> backends;

  MultiBackendRemoteService({
    required this.enabledBackends,
    required this.backends,
  });

  @override
  Future<void> saveRaw(
    String coll,
    String id,
    Map<String, dynamic> data,
  ) async {
    final futures = enabledBackends
        .map((mode) => backends[mode]?.saveRaw(coll, id, data))
        .whereType<Future<void>>();

    await Future.wait(futures);
  }

  @override
  Future<Map<String, dynamic>> getRaw(String coll, String id) async {
    for (var mode in enabledBackends) {
      final backend = await backends[mode]?.getRaw(coll, id) ?? {};
      if (backend.isNotEmpty) return backend;
    }

    return {};
  }

  @override
  Future<List<Map<String, dynamic>>> getAllRaw(
    String coll, {
    DateTime? updatedAfter,
    int? limit,
  }) async {
    final primary = backends[enabledBackends.first];
    return await primary?.getAllRaw(
          coll,
          updatedAfter: updatedAfter,
          limit: limit,
        ) ??
        [];
  }

  @override
  Stream<List<Map<String, dynamic>>> watchCollectionRaw(
    String coll, {
    Function(dynamic query)? queryBuilder,
  }) {
    // On écoute le stream du backend principal
    return backends[enabledBackends.first]?.watchCollectionRaw(
          coll,
          queryBuilder: queryBuilder,
        ) ??
        Stream.value([]);
  }

  @override
  Future<void> deleteRaw(String coll, String id) async {
    await Future.wait(
      enabledBackends
          .map((mode) => backends[mode]?.deleteRaw(coll, id))
          .whereType<Future<void>>(),
    );
  }
}
