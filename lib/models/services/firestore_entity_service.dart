import 'package:bat_track_v1/data/local/models/index_model_extention.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/remote/services/firebase_service.dart';
import '../../models/data/json_model.dart';
import '../../models/data/maperror/logged_action.dart';
import '../data/adapter/safe_async_mixin.dart';
import 'entity_service.dart';

class FirestoreEntityService<T extends JsonModel>
    with LoggedAction, SafeAsyncMixin<T>
    implements EntityService<T> {
  final String collectionPath;
  final T Function(Map<String, dynamic>) fromJson;
  final Ref ref;
  Function(dynamic query)? queryBuilder;

  FirestoreEntityService({
    required this.collectionPath,
    required this.fromJson,
    required this.ref,
    this.queryBuilder,
  }) {
    initSafeAsync(ref);
  }

  @override
  Future<void> save(T entity, String id) async {
    await safeVoid(
      () => FirestoreService.setData<T>(
        collectionPath: collectionPath,
        docId: id,
        data: entity,
      ),
      context: 'save($id)',
      logError: true,
    );
  }

  @override
  Future<T?> get(String id) async {
    return await safeAsync<T?>(
      () => FirestoreService.getData<T?>(
        collectionPath: collectionPath,
        docId: id,
        fromJson: fromJson,
      ).then((value) => value ?? AppUser.empty() as T),
      context: 'get($id)',
      fallback: AppUser.empty() as T,
      logError: true,
    );
  }

  @override
  Future<List<T>> getAll() async {
    return await safeAsync<List<T>>(
      () => FirestoreService.getAll<T>(
        collectionPath: collectionPath,
        fromJson: fromJson,
      ),
      context: 'getAll()',
      fallback: [],
      logError: true,
    );
  }

  @override
  Future<void> delete(String id) async {
    await safeVoid(
      () => FirestoreService.deleteData(
        collectionPath: collectionPath,
        docId: id,
      ),
      context: 'delete($id)',
      logError: true,
    );
  }

  @override
  Future<void> update(T entity, String id) => save(entity, id);

  @override
  Future<bool> exists(String id) async => (await get(id)) != null;

  @override
  Future<List<String>> getKeys() async {
    final docs = await getAll();
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
