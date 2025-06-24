import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // CREATE / UPDATE avec set (merge: true pour update partiel)
  static Future<void> setData<T>({
    required String collectionPath,
    required String docId,
    required Map<String, dynamic> data,
  }) async {
    await _db
        .collection(collectionPath)
        .doc(docId)
        .set(data, SetOptions(merge: true));
  }

  // READ un document par id
  static Future<T?> getData<T>({
    required String collectionPath,
    required String docId,
    required T Function(Map<String, dynamic> json) fromJson,
  }) async {
    final doc = await _db.collection(collectionPath).doc(docId).get();
    if (doc.exists && doc.data() != null) {
      return fromJson(doc.data()!);
    }
    return null;
  }

  // READ tous les documents d'une collection
  static Future<List<T>> getAll<T>({
    required String collectionPath,
    required T Function(Map<String, dynamic> json) fromJson,
  }) async {
    final snapshot = await _db.collection(collectionPath).get();
    return snapshot.docs.map((doc) => fromJson(doc.data())).toList();
  }

  // DELETE document par id
  static Future<void> deleteData({
    required String collectionPath,
    required String docId,
  }) async {
    await _db.collection(collectionPath).doc(docId).delete();
  }
}
