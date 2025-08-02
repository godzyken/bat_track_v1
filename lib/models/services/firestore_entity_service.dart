import 'package:bat_track_v1/models/data/json_model.dart';

import '../../data/remote/services/firebase_service.dart';
import 'entity_service.dart';

class FirestoreEntityService<T extends JsonModel> implements EntityService<T> {
  final String collectionPath;
  final T Function(Map<String, dynamic>) fromJson;

  FirestoreEntityService({
    required this.collectionPath,
    required this.fromJson,
  });

  @override
  Future<void> save(T entity, String id) async {
    await FirestoreService.setData(
      collectionPath: collectionPath,
      docId: id,
      data: entity,
    );
  }

  @override
  Future<T?> get(String id) async {
    return await FirestoreService.getData(
      collectionPath: collectionPath,
      docId: id,
      fromJson: fromJson,
    );
  }

  @override
  Future<List<T>> getAll() async {
    return await FirestoreService.getAll(
      collectionPath: collectionPath,
      fromJson: fromJson,
    );
  }

  @override
  Future<void> delete(String id) async {
    await FirestoreService.deleteData(
      collectionPath: collectionPath,
      docId: id,
    );
  }

  // Tu peux compléter les autres méthodes (update, query, etc.) plus tard si besoin
  @override
  Future<void> update(T entity, String id) => save(entity, id);

  @override
  Future<bool> exists(String id) async => (await get(id)) != null;

  @override
  Future<List<String>> getKeys() async {
    final docs = await FirestoreService.getAll(
      collectionPath: collectionPath,
      fromJson: fromJson,
    );
    return docs.map((e) => e.id).toList();
  }

  @override
  T? getById(String id) => throw UnimplementedError();

  @override
  Future<void> deleteAll() => throw UnimplementedError();

  @override
  Future<void> deleteByQuery(String query) => throw UnimplementedError();

  @override
  Future<void> clear() => throw UnimplementedError();

  @override
  Future<void> closeAll() => throw UnimplementedError();

  @override
  Future<void> init() => throw UnimplementedError();

  @override
  Future<void> open() => throw UnimplementedError();

  @override
  Future<List<T>> query(String query) => throw UnimplementedError();

  @override
  Future<List<T>> sortedBy(
    Comparable Function(T p1), {
    bool descending = false,
  }) => throw UnimplementedError();

  @override
  Future<List<T>> where(bool Function(T p1)) => throw UnimplementedError();
}
