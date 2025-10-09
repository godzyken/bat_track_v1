import 'dart:async';

import 'package:bat_track_v1/data/core/unified_model.dart';
import 'package:bat_track_v1/models/data/adapter/no_such_methode_logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/services/service_type.dart';
import '../../data/remote/services/firestore_service.dart';
import '../../models/data/maperror/logged_action.dart';
import '../data/adapter/safe_async_mixin.dart';

class FirestoreEntityService<T extends UnifiedModel>
    with LoggedAction, SafeAsyncMixin<T>, NoSuchMethodLogger
    implements EntityServices<T> {
  final String collectionPath;
  @override
  final T Function(Map<String, dynamic>) fromJson;
  final Function(dynamic query)? queryBuilder;
  late Ref ref;

  FirestoreEntityService({
    required this.collectionPath,
    required this.fromJson,
    this.queryBuilder,
  });

  void initWithRef(Ref ref) {
    this.ref = ref;
    initSafeAsync(ref.read);
  }

  @override
  dynamic get proxyTarget => ref;

  @override
  Future<void> save(T item, [String? id]) async {
    await safeVoid(
      () => FirestoreService.setData<T>(
        collectionPath: collectionPath,
        docId: id!,
        data: item,
      ),
      context: 'save($id)',
      logError: true,
    );
  }

  @override
  Future<T?> getById(String id) async {
    return await safeAsync<T?>(
      () => FirestoreService.getData<T?>(
        collectionPath: collectionPath,
        docId: id,
        fromJson: fromJson,
      ),
      context: 'getById($id)',
      fallback: null,
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
  Stream<List<T>> watchAll() {
    Query<Map<String, dynamic>> Function(Query<Map<String, dynamic>>)?
    typedQueryBuilder;

    if (queryBuilder != null) {
      typedQueryBuilder =
          (query) => queryBuilder!(query) as Query<Map<String, dynamic>>;
    }

    return FirestoreService.watchCollection<T>(
      collectionPath: collectionPath,
      fromJson: fromJson,
      queryBuilder: typedQueryBuilder,
    );
  }

  /// Optionnel : watcher filtré par chantierId
  @override
  Stream<List<T>> watchByChantier(String chantierId) {
    return FirestoreService.watchCollection<T>(
      collectionPath: collectionPath,
      fromJson: fromJson,
      queryBuilder: (query) => query.where('chantierId', isEqualTo: chantierId),
    );
  }
}

class FirestoreEntityServiceConfig<T extends UnifiedModel> {
  final String collectionPath;
  final T Function(Map<String, dynamic>) fromJson;

  const FirestoreEntityServiceConfig({
    required this.collectionPath,
    required this.fromJson,
  });
}
