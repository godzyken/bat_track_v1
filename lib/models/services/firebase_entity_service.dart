import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/services/unified_entity_service.dart';
import '../../data/core/unified_model.dart';

class FirebaseEntityService<T extends UnifiedModel>
    implements UnifiedEntityService<T> {
  final String collectionPath;
  @override
  final T Function(Map<String, dynamic> json) fromJson;

  FirebaseEntityService({required this.collectionPath, required this.fromJson});

  CollectionReference<Map<String, dynamic>> get _collection =>
      FirebaseFirestore.instance
              .collection(collectionPath)
              .withConverter<T>(
                fromFirestore: (snapshot, _) => fromJson(snapshot.data()!),
                toFirestore: (model, _) => model.toJson(),
              )
          as CollectionReference<Map<String, dynamic>>;

  @override
  Future<void> deleteByQuery(Map<String, dynamic> query) async {
    if (query.isEmpty) return;

    // On ne gère qu'un seul champ pour simplifier
    final fieldName = query.keys.first;
    final value = query[fieldName];

    final querySnapshot =
        await _collection.where(fieldName, isEqualTo: value).get();
    for (var doc in querySnapshot.docs) {
      await doc.reference.delete();
    }
  }

  @override
  Future<List<T>> getAll() async {
    final querySnapshot = await _collection.get();
    return querySnapshot.docs.map((doc) => fromJson(doc.data())).toList();
  }

  @override
  Future<T?> getById(String id) async {
    final snapshot = await _collection.doc(id).get();
    if (!snapshot.exists) return null;
    return fromJson(snapshot.data()!);
  }

  @override
  Future<void> save(T entity, [String? id]) async {
    await _collection.doc(id).set(entity.toJson());
  }

  @override
  Stream<List<T>> watchAll() {
    return _collection.snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => fromJson(doc.data())).toList(),
    );
  }

  Stream<T?> watchById(String id) {
    return _collection
        .doc(id)
        .snapshots()
        .map((snapshot) => snapshot.exists ? fromJson(snapshot.data()!) : null);
  }

  @override
  Future<void> delete(String id) async {
    await _collection.doc(id).delete();
  }

  void _log(String method, List<dynamic> args) {
    developer.log('[LOG][${T.toString()}] $method called with args: $args');
  }

  @override
  noSuchMethod(Invocation invocation) {
    // Log du nom et des arguments
    _log(invocation.memberName.toString(), invocation.positionalArguments);

    try {
      // Délégation automatique à _delegate
      return Function.apply((_collection as dynamic).noSuchMethod, [
        invocation,
      ]);
    } catch (_) {
      return super.noSuchMethod(invocation);
    }
  }
}
