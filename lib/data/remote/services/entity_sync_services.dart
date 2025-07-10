import 'package:bat_track_v1/data/local/models/base/has_files.dart';
import 'package:bat_track_v1/data/local/services/hive_service.dart';
import 'package:bat_track_v1/data/remote/services/firebase_service.dart';
import 'package:bat_track_v1/data/remote/services/storage_service.dart';
import 'package:bat_track_v1/models/data/json_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/chantier/controllers/providers/chantier_sync_provider.dart';

class EntitySyncService<T extends JsonModel> {
  final String boxName;
  final FirebaseStorage storage;
  final FirebaseFirestore firestore;

  EntitySyncService(this.boxName)
    : storage = FirebaseStorage.instance,
      firestore = FirebaseFirestore.instance;

  /// 🔁 Sync vers Hive + Firestore (+ Storage si HasFile)
  Future<void> save(T item, {String? id}) async {
    final docId = id ?? item.id;

    // ✅ Sauvegarde Hive locale
    await HiveService.put<T>(boxName, docId!, item);

    // ✅ Sauvegarde dans Firestore
    await FirestoreService.setData<T>(
      collectionPath: boxName,
      docId: docId,
      data: item.toJson(),
    );

    // 📂 Sauvegarde le fichier dans Firebase Storage si applicable
    if (item is HasFile) {
      final file = (item as HasFile).getFile();
      final fileName = file.path.split('/').last;
      final path = '$boxName/$docId/$fileName';
      await StorageService(storage).uploadFile(file, path);
    }
  }

  /// 🗑 Supprimer sur Hive + Firestore
  Future<void> delete(String id) async {
    await HiveService.delete<T>(boxName, id);
    await firestore.collection(boxName).doc(id).delete();
  }

  /// 🧾 Lecture locale
  Future<List<T>> getAll() => HiveService.getAll<T>(boxName);

  /// 🔄 Synchronisation depuis Firestore vers Hive
  Future<void> syncFromFirestore() async {
    final snapshot = await firestore.collection(boxName).get();
    for (var doc in snapshot.docs) {
      final json = doc.data();
      final item = JsonModel.fromDynamic<T>(json);
      if (item != null) {
        await HiveService.put<T>(boxName, doc.id, item);
      }
    }
  }

  /// 🔍 Récupère un document depuis Firestore et met à jour Hive
  Future<T?> getByIdFromFirestore(String id) async {
    final doc = await firestore.collection(boxName).doc(id).get();
    if (!doc.exists) return null;
    final data = doc.data()!;
    final item = JsonModel.fromDynamic<T>(data);
    if (item != null) {
      await HiveService.put<T>(boxName, id, item);
    }
    return item;
  }

  /// 🔄 Synchronise un seul objet local sur Firestore/Storage
  Future<void> syncOne(T item) async {
    await save(item, id: item.id);
  }

  /// 🔁 Vérifie si un document existe en distant
  Future<bool> existsInFirestore(String id) async {
    final doc = await firestore.collection(boxName).doc(id).get();
    return doc.exists;
  }
}

/// 🔁 Synchroniser toutes les entités en une seule commande
Future<void> syncAllEntitiesFromFirestore(Ref ref) async {
  await ref.read(chantierSyncServiceProvider).syncFromFirestore();
  await ref.read(pieceJointeSyncServiceProvider).syncFromFirestore();
  await ref.read(materielSyncServiceProvider).syncFromFirestore();
  await ref.read(materiauSyncServiceProvider).syncFromFirestore();
  await ref.read(mainOeuvreSyncServiceProvider).syncFromFirestore();
  await ref.read(techSyncServiceProvider).syncFromFirestore();
  await ref.read(clientSyncServiceProvider).syncFromFirestore();
  await ref.read(interventionSyncServiceProvider).syncFromFirestore();
  await ref.read(pieceSyncServiceProvider).syncFromFirestore();
  //await ref.read(factureSyncServiceProvider).syncFromFirestore();
  //await ref.read(projetSyncServiceProvider).syncFromFirestore();
}
