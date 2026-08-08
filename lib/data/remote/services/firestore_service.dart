import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/services/remote/remote_storage_service.dart';

class FirestoreService extends RemoteStorageService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  bool get isConnected => true; // À implémenter avec un vrai check si besoin

  @override
  Future<Map<String, dynamic>> getRaw(String collectionPath, String id) async {
    final sw = Stopwatch()..start();
    log('📥 getRaw -> $collectionPath/$id');

    final doc = await _db.collection(collectionPath).doc(id).get();

    sw.stop();
    log('✅ getRaw terminé en ${sw.elapsedMilliseconds}ms');

    if (doc.exists && doc.data() != null) {
      final data = doc.data()!;
      data['id'] = doc.id;
      return data;
    }
    return {};
  }

  @override
  Future<void> saveRaw(
    String collectionPath,
    String id,
    Map<String, dynamic> data,
  ) async {
    final sw = Stopwatch()..start();
    log('📤 saveRaw -> $collectionPath/$id');

    // On s'assure que l'ID est dans le corps du document
    final dataToSave = Map<String, dynamic>.from(data);
    dataToSave['id'] = id;

    await _db
        .collection(collectionPath)
        .doc(id)
        .set(dataToSave, SetOptions(merge: true));

    sw.stop();
    log('✅ saveRaw terminé en ${sw.elapsedMilliseconds}ms');
  }

  @override
  Future<List<Map<String, dynamic>>> getAllRaw(
    String collectionPath, {
    DateTime? updatedAfter,
    int? limit,
  }) async {
    Query<Map<String, dynamic>> query = _db.collection(collectionPath);

    if (updatedAfter != null) {
      query = query.where('updatedAt', isGreaterThan: updatedAfter);
    }
    if (limit != null) {
      query = query.limit(limit);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  @override
  Stream<List<Map<String, dynamic>>> watchCollectionRaw(
    String collectionPath, {
    dynamic Function(dynamic query)? queryBuilder,
  }) {
    Query<Map<String, dynamic>> query = _db.collection(collectionPath);

    if (queryBuilder != null) {
      query = queryBuilder(query) as Query<Map<String, dynamic>>;
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  @override
  Future<void> deleteRaw(String collectionPath, String id) async {
    log('🗑️ deleteRaw -> $collectionPath/$id');
    await _db.collection(collectionPath).doc(id).delete();
  }
}
