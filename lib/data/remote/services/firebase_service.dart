import 'dart:developer';

import 'package:bat_track_v1/models/data/json_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// 🔄 CREATE or UPDATE
  static Future<void> setData<T extends JsonModel>({
    required String collectionPath,
    required String docId,
    required T data,
  }) async {
    final sw = Stopwatch()..start();
    log('📤 setData -> $collectionPath/$docId');

    await _db
        .collection(collectionPath)
        .doc(docId)
        .set(data.toJson(), SetOptions(merge: true));

    sw.stop();
    log('✅ setData terminé en ${sw.elapsedMilliseconds}ms');
  }

  /// 🔍 READ un document par id
  static Future<T?> getData<T>({
    required String collectionPath,
    required String docId,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    final sw = Stopwatch()..start();
    log('📥 getData -> $collectionPath/$docId');

    final doc = await _db.collection(collectionPath).doc(docId).get();

    sw.stop();
    log('✅ getData terminé en ${sw.elapsedMilliseconds}ms');

    if (doc.exists && doc.data() != null) {
      return fromJson(doc.data()!);
    }
    return null;
  }

  /// 🔁 READ tous les documents, avec filtrage
  static Future<List<T>> getAll<T>({
    required String collectionPath,
    required T Function(Map<String, dynamic>) fromJson,
    DateTime? updatedAfter, // Limiter les documents modifiés récemment
    int limitTo = 20,
  }) async {
    final sw = Stopwatch()..start();
    log('📥 getAll -> $collectionPath (limit: $limitTo)');

    Query<Map<String, dynamic>> query = _db.collection(collectionPath);

    if (updatedAfter != null) {
      query = query.where('updatedAt', isGreaterThan: updatedAfter);
    }

    query = query.limit(limitTo);

    final snapshot = await query.get();
    final results = snapshot.docs.map((doc) => fromJson(doc.data())).toList();

    sw.stop();
    log(
      '✅ getAll terminé en ${sw.elapsedMilliseconds}ms avec ${results.length} documents',
    );

    return results;
  }

  /// 🗑️ DELETE
  static Future<void> deleteData({
    required String collectionPath,
    required String docId,
  }) async {
    log('🗑️ deleteData -> $collectionPath/$docId');
    await _db.collection(collectionPath).doc(docId).delete();
  }
}
