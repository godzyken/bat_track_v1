import 'dart:developer' as developer;

import 'package:bat_track_v1/models/data/adapter/no_such_methode_logger.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/services/remote/remote_storage_service.dart';

class CloudFlareService extends RemoteStorageService with NoSuchMethodLogger {
  CloudFlareService._();
  static final CloudFlareService instance = CloudFlareService._();

  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  dynamic get proxyTarget => _db;

  /// 🔍 Récupère un enregistrement brut
  @override
  Future<Map<String, dynamic>> getRaw(String collectionPath, String id) async {
    try {
      final doc = await _db.collection(collectionPath).doc(id).get();
      if (!doc.exists || doc.data() == null) return {};
      final data = Map<String, dynamic>.from(doc.data()!);
      data['id'] = doc.id;
      return data;
    } catch (e, st) {
      developer.log('CloudFlareService.getRaw error: $e\n$st');
      rethrow;
    }
  }

  /// 💾 Enregistre ou met à jour
  @override
  Future<void> saveRaw(
    String collectionPath,
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      await _db
          .collection(collectionPath)
          .doc(id)
          .set(data, SetOptions(merge: true));
    } catch (e, st) {
      developer.log('CloudFlareService.saveRaw error: $e\n$st');
      rethrow;
    }
  }

  /// 🗑 Supprime
  @override
  Future<void> deleteRaw(String collectionPath, String id) async {
    try {
      await _db.collection(collectionPath).doc(id).delete();
    } catch (e, st) {
      developer.log('CloudFlareService.deleteRaw error: $e\n$st');
      rethrow;
    }
  }

  /// 📜 Récupère tous les enregistrements
  @override
  Future<List<Map<String, dynamic>>> getAllRaw(
    String collectionPath, {
    DateTime? updatedAfter,
    int? limit,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _db.collection(collectionPath);
      if (updatedAfter != null) {
        query = query.where('updatedAt', isGreaterThan: updatedAfter);
      }
      if (limit != null) {
        query = query.limit(limit);
      }
      final snapshot = await query.get();
      return snapshot.docs.map((doc) {
        final data = Map<String, dynamic>.from(doc.data());
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e, st) {
      developer.log('CloudFlareService.getAllRaw error: $e\n$st');
      rethrow;
    }
  }

  @override
  Stream<List<Map<String, dynamic>>> watchCollectionRaw(
    String collectionPath, {
    dynamic Function(Query<Map<String, dynamic>> query)? queryBuilder,
  }) {
    Query<Map<String, dynamic>> query = _db.collection(collectionPath);
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
