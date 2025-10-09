import '../../../data/core/unified_model.dart';
import '../../../data/remote/services/firestore_service.dart';
import '../adapter/typedefs.dart';

abstract class BaseRepository<T extends UnifiedModel> {
  final String collectionPath;
  final T Function(Map<String, dynamic>) fromJson;

  const BaseRepository(this.collectionPath, this.fromJson);

  Future<T?> getById(String id) {
    return FirestoreService.getData(
      collectionPath: collectionPath,
      docId: id,
      fromJson: fromJson,
    );
  }

  Future<List<T>> getAll({int limit = 20}) {
    return FirestoreService.getAll(
      collectionPath: collectionPath,
      fromJson: fromJson,
      limitTo: limit,
    );
  }

  Future<List<T>> getFiltered({required QueryBuilder queryBuilder}) {
    return FirestoreService.getFiltered(
      collectionPath: collectionPath,
      fromJson: fromJson,
      queryBuilder: queryBuilder,
    );
  }

  Stream<List<T>> watchFiltered({required QueryBuilder queryBuilder}) {
    return FirestoreService.watchCollection(
      collectionPath: collectionPath,
      fromJson: fromJson,
      queryBuilder: queryBuilder,
    );
  }

  Future<void> set(T data) {
    return FirestoreService.setData(
      collectionPath: collectionPath,
      docId: data.id,
      data: data,
    );
  }

  Future<void> delete(String id) {
    return FirestoreService.deleteData(
      collectionPath: collectionPath,
      docId: id,
    );
  }
}
