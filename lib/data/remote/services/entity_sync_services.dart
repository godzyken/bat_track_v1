import 'dart:developer' as developer;

import 'package:bat_track_v1/data/local/services/hive_service.dart';
import 'package:bat_track_v1/data/remote/services/firebase_service.dart';
import 'package:bat_track_v1/data/remote/services/storage_service.dart';
import 'package:bat_track_v1/models/data/json_model.dart';
import 'package:bat_track_v1/models/providers/synchrones/facture_sync_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/chantier/controllers/providers/chantier_sync_provider.dart';
import '../../local/models/index_model_extention.dart';

class EntitySyncService<T extends JsonModel> {
  static final _cacheTimestamps = <String, DateTime>{};
  static const Duration ttl = Duration(seconds: 60);

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
    await HiveService.put<T>(boxName, docId, item);

    // ✅ Sauvegarde dans Firestore
    await FirestoreService.setData<T>(
      collectionPath: boxName,
      docId: docId,
      data: item,
    );

    // 📂 Sauvegarde le fichier dans Firebase Storage si applicable
    if (item is HasFile) {
      final file = (item as HasFile).getFile();
      final fileName = file.path.split('/').last;
      final path = '$boxName/$docId/$fileName';
      await StorageService(storage).uploadFile(file, path);
    }

    if (item is PieceJointe) {
      // ⚠️ Nécessite un `BuildContext`, on ne peut pas précacher sans contexte ici
      developer.log(
        '💡 Note: Impossible de précacher ici sans BuildContext. Utilise plutôt precacheAllWithContext() après.',
      );
    }
  }

  /// 🗑 Supprimer sur Hive + Firestore
  Future<void> delete(String id) async {
    await HiveService.delete<T>(boxName, id);
    await firestore.collection(boxName).doc(id).delete();
  }

  /// 🧾 Lecture locale
  Future<List<T>> getAll() async {
    final now = DateTime.now();
    final lastFetch = _cacheTimestamps[boxName];
    if (lastFetch != null && now.difference(lastFetch) < ttl) {
      developer.log('⛔ [EntitySync:$boxName] getAll() ignoré (TTL actif)');
      return HiveService.getAll<T>(boxName);
    }

    _cacheTimestamps[boxName] = now;

    final sw = Stopwatch()..start();
    developer.log('⏳ [FileSync:$boxName] getAll started');

    // 1. Récupère les entités depuis Firestore (avec filtre + limite)
    final modelsFromCloud = await FirestoreService.getAll(
      collectionPath: boxName,
      fromJson:
          JsonModelFactory.fromDynamic as T Function(Map<String, dynamic>),
      updatedAfter: DateTime.now().subtract(const Duration(days: 7)),
      limitTo: 100,
    );

    // 2. Pour chaque modèle, on stocke dans Hive et on télécharge le fichier si besoin
    for (final model in modelsFromCloud) {
      final id = model.id;

      await HiveService.put<T>(boxName, id, model);

      if (model is HasFile) {
        final fileItem = model as HasFile; // ✅ Cast explicite

        final fileName = fileItem.getFile().path.split('/').last;
        final path = '$boxName/$id/$fileName';

        final exists = await storage
            .ref(path)
            .getDownloadURL()
            .then((_) => true)
            .catchError((_) => false);
        if (exists) {
          developer.log(
            '📦 Fichier $fileName déjà dans Firebase, download si nécessaire…',
          );
          // Tu peux ici ajouter une logique de download local ou cache si tu veux
        }
      }
    }

    sw.stop();
    developer.log(
      '✅ [FileSync:$boxName] getAll terminé en ${sw.elapsedMilliseconds}ms',
    );
    return modelsFromCloud;
  }

  /// 🔄 Synchronisation depuis Firestore vers Hive
  Future<void> syncFromFirestore({BuildContext? context}) async {
    final sw = Stopwatch()..start();
    developer.log('🚀 Début $boxName.syncFromFirestore()');

    final now = DateTime.now();
    final since = now.subtract(const Duration(days: 7));

    final query = firestore
        .collection(boxName)
        .where('updatedAt', isGreaterThan: since)
        .limit(50); // 🧠 Soft-limit Firestore (préventif)

    final snapshot = await query.get();
    developer.log('🔁 [Sync:$boxName] ${snapshot.size} docs récupérés');

    for (var doc in snapshot.docs) {
      final json = doc.data();
      final item = JsonModelFactory.fromDynamic<T>(json);
      if (item != null) {
        await HiveService.put<T>(boxName, doc.id, item);
        if ((item is HasFile || item is PieceJointe) &&
            context?.mounted == true) {
          await HiveService.precachePieceJointe<T>(context!, boxName, item);
        }
      }
    }

    developer.log('✅ Terminé ${sw.elapsedMilliseconds}ms');
  }

  /// 🔍 Récupère un document depuis Firestore et met à jour Hive
  Future<T?> getByIdFromFirestore(String id) async {
    final doc = await firestore.collection(boxName).doc(id).get();
    if (!doc.exists) return null;
    final data = doc.data()!;
    final item = JsonModelFactory.fromDynamic<T>(data);
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

  Future<void> precacheAllWithContext(BuildContext context) async {
    final items = await HiveService.getAll<T>(boxName);
    for (final item in items) {
      if (item is PieceJointe && context.mounted) {
        await HiveService.precachePieceJointe<PieceJointe>(
          context,
          boxName,
          item,
        );
      }
    }
  }

  /// 🔼 Envoie toutes les entités Hive modifiées vers Firestore
  Future<void> syncToFirestore() async {
    final localItems = await HiveService.getAll<T>(boxName);
    final collection = firestore.collection(boxName);

    for (final item in localItems) {
      final doc = await collection.doc(item.id).get();
      final exists = doc.exists;

      if (!exists || _isLocalNewer(item, doc)) {
        await save(item); // ⬅️ Cela gère Hive + Firestore + Storage
      }
    }
  }

  /// Compare les dates de mise à jour pour détecter un besoin de sync
  bool _isLocalNewer(T item, DocumentSnapshot<Map<String, dynamic>> doc) {
    try {
      final remoteUpdatedAt =
          (doc.data()?['updatedAt'] as Timestamp?)?.toDate();
      return remoteUpdatedAt == null ||
          item.updatedAt!.isAfter(remoteUpdatedAt);
    } catch (e) {
      return true; // Si doute, push
    }
  }

  /// Ecoute les changements en temps réel
  Stream<List<T>> watchAll() async* {
    final box = await HiveService.box<T>(boxName);
    yield box.values.toList(); // première émission

    // ensuite écoute les changements :
    yield* box.watch().map((_) => box.values.toList());
  }
}

/// 🔁 Synchroniser toutes les entités en une seule commande
Future<void> syncAllEntitiesFromFirestore(Ref ref) async {
  final sw = Stopwatch()..start();
  developer.log('🚀 Démarrage syncAllEntities');

  final syncs = [
    ref.read(chantierSyncServiceProvider).syncFromFirestore(),
    ref.read(pieceJointeSyncServiceProvider).syncFromFirestore(),
    ref.read(materielSyncServiceProvider).syncFromFirestore(),
    ref.read(materiauSyncServiceProvider).syncFromFirestore(),
    ref.read(mainOeuvreSyncServiceProvider).syncFromFirestore(),
    ref.read(techSyncServiceProvider).syncFromFirestore(),
    ref.read(clientSyncServiceProvider).syncFromFirestore(),
    ref.read(interventionSyncServiceProvider).syncFromFirestore(),
    ref.read(pieceSyncServiceProvider).syncFromFirestore(),
    ref.read(factureSyncServiceProvider).syncFromFirestore(),
    ref.read(projetSyncServiceProvider).syncFromFirestore(),
    ref.read(invoiceSyncServiceProvider).syncFromFirestore(),
  ];

  await Future.wait(syncs);

  sw.stop();
  developer.log('✅ syncAllEntities terminé en ${sw.elapsedMilliseconds}ms');
}
