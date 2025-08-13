import 'dart:developer' as developer;

import 'package:bat_track_v1/models/services/remote/remote_storage_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService implements RemoteStorageService {
  FirebaseService._();
  static final FirebaseService instance = FirebaseService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Récupère le document raw (Map). Retourne {} si absent.
  @override
  Future<Map<String, dynamic>> getRaw(String collection, String id) async {
    try {
      final doc = await _firestore.collection(collection).doc(id).get();
      if (!doc.exists) return {};
      final data = doc.data()!;
      // inject id pour plus de commodité
      return {'id': doc.id, ...data};
    } catch (e, st) {
      developer.log('FirebaseService.getRaw error: $e\n$st');
      rethrow;
    }
  }

  /// Ecrit/merge la Map dans Firestore
  @override
  Future<void> saveRaw(
    String collection,
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore
          .collection(collection)
          .doc(id)
          .set(data, SetOptions(merge: true));
    } catch (e, st) {
      developer.log('FirebaseService.saveRaw error: $e\n$st');
      rethrow;
    }
  }

  /// Supprime le document
  @override
  Future<void> deleteRaw(String collection, String id) async {
    try {
      await _firestore.collection(collection).doc(id).delete();
    } catch (e, st) {
      developer.log('FirebaseService.deleteRaw error: $e\n$st');
      rethrow;
    }
  }

  /// Récupère tous les docs (raw), optionnellement filtrés par updatedAfter et limit.
  @override
  Future<List<Map<String, dynamic>>> getAllRaw(
    String collection, {
    DateTime? updatedAfter,
    int? limit,
  }) async {
    try {
      Query q = _firestore.collection(collection);
      if (updatedAfter != null) {
        q = q.where(
          'updatedAt',
          isGreaterThan: Timestamp.fromDate(updatedAfter),
        );
      }
      if (limit != null) q = q.limit(limit);
      final snap = await q.get();
      return snap.docs.map((d) {
        final data = d.data() as Map<String, dynamic>? ?? {};
        return {'id': d.id, ...data};
      }).toList();
    } catch (e, st) {
      developer.log('FirebaseService.getAllRaw error: $e\n$st');
      rethrow;
    }
  }

  /// Utilité : obtenir des modèles typés directement
  Future<List<T>> getAll<T>(
    String collection,
    T Function(Map<String, dynamic>) fromJson, {
    DateTime? updatedAfter,
    int? limit,
  }) async {
    final raws = await getAllRaw(
      collection,
      updatedAfter: updatedAfter,
      limit: limit,
    );
    return raws.map((r) => fromJson(r)).toList();
  }

  @override
  Stream<List<Map<String, dynamic>>> watchCollectionRaw(
    String collectionOrTable, {
    dynamic Function(dynamic query)? queryBuilder,
  }) {
    Query<Map<String, dynamic>> query = _firestore.collection(
      collectionOrTable,
    );
    if (queryBuilder != null) {
      query = queryBuilder(query);
    }
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }
}
