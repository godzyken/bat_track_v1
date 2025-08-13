import 'dart:developer' as developer;

import 'package:async/async.dart';
import 'package:bat_track_v1/data/local/services/hive_service.dart';
import 'package:bat_track_v1/data/remote/services/storage_service.dart';
import 'package:bat_track_v1/models/data/json_model.dart';
import 'package:bat_track_v1/models/providers/asynchrones/remote_service_provider.dart';
import 'package:bat_track_v1/models/providers/synchrones/facture_sync_provider.dart';
import 'package:bat_track_v1/models/services/cloud_flare_entity_service.dart';
import 'package:bat_track_v1/models/services/firebase_entity_service.dart';
import 'package:bat_track_v1/models/services/firestore_entity_service.dart';
import 'package:bat_track_v1/models/services/remote/remote_entity_service_adapter.dart';
import 'package:bat_track_v1/models/services/supabase_entity_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/models/index_model_extention.dart';
import '../../data/local/services/service_type.dart';
import '../../features/chantier/controllers/providers/chantier_sync_provider.dart';
import 'hive_entity_service.dart';
import 'multi_backend_remote_service.dart';

abstract class EntityLocalService<T> implements HiveService {
  Future<void> put(String id, T item);
  Future<T?> get(String id);
  Future<List<T>> getAll();
  Future<void> delete(String id);
  Stream<List<T>> watchAll();
}

abstract class EntityRemoteService<T> {
  Future<void> save(T item, String id);
  Future<T?> getById(String id);
  Future<List<T>> getAll();
  Future<void> delete(String id);
  Stream<List<T>> watchAll();
}

class EntitySyncService<T extends JsonModel> {
  static final _cacheTimestamps = <String, DateTime>{};
  static const Duration ttl = Duration(seconds: 60);

  final EntityLocalService<T> local;
  final EntityRemoteService<T> remote;

  EntitySyncService(this.local, this.remote);

  /// 🔁 Sauvegarde local + remote (+ fichier si HasFile)
  Future<void> save(T item, {String? id}) async {
    final docId = id ?? item.id;

    await Future.wait([local.put(docId, item), remote.save(item, docId)]);

    if (item is HasFile) {
      await _handleFileUpload(item as HasFile, docId);
    }

    if (item is PieceJointe) {
      developer.log(
        '💡 Impossible de précacher ici sans BuildContext. Utiliser precacheAllWithContext() après.',
      );
    }
  }

  Future<void> _handleFileUpload(HasFile item, String docId) async {
    try {
      final file = item.getFile();
      final fileName = file.path.split('/').last;
      final path = '${T.toString()}/$docId/$fileName';

      await StorageService(FirebaseStorage.instance).uploadFile(file, path);
      developer.log('📁 Fichier uploadé: $path');
    } catch (e) {
      developer.log('❌ Erreur upload fichier: $e');
    }
  }

  /// 🗑 Supprime local + remote
  Future<void> delete(String id) async {
    await local.delete(id);
    await remote.delete(id);
  }

  /// 🧾 Lecture avec TTL cache
  Future<List<T>> getAll() async {
    final now = DateTime.now();
    final lastFetch = _cacheTimestamps[T.toString()];
    if (lastFetch != null && now.difference(lastFetch) < ttl) {
      developer.log('⛔ [EntitySync:$T] getAll ignoré (TTL actif)');
      return local.getAll();
    }

    _cacheTimestamps[T.toString()] = now;

    final sw = Stopwatch()..start();
    developer.log('⏳ [EntitySync:$T] getAll started');

    final modelsFromCloud = await remote.getAll();

    for (final model in modelsFromCloud) {
      await local.put(model.id, model);

      if (model is HasFile) {
        // Ici tu peux rajouter ta logique de download/cache fichier
      }
    }

    sw.stop();
    developer.log(
      '✅ [EntitySync:$T] getAll terminé en ${sw.elapsedMilliseconds}ms',
    );
    return modelsFromCloud;
  }

  /// Récupération uniquement locale
  Future<List<T>> getAllFromLocal() => local.getAll();

  Future<T?> getByIdFromLocal(String id) => local.get(id);

  Future<T?> getByIdFromRemote(String id) async {
    final remoteItem = await remote.getById(id);
    if (remoteItem != null) {
      await local.put(id, remoteItem);
    }
    return remoteItem;
  }

  /// 🔄 Synchronisation depuis le remote vers le local
  Future<void> syncFromRemote({BuildContext? context}) async {
    final sw = Stopwatch()..start();
    developer.log('🚀 Début syncFromRemote()');

    final remoteItems = await remote.getAll();
    developer.log('🔁 ${remoteItems.length} éléments récupérés');

    for (final item in remoteItems) {
      await local.put(item.id, item);
      if ((item is HasFile || item is PieceJointe) &&
          context?.mounted == true) {
        await HiveService.precachePieceJointe<T>(context!, T.toString(), item);
      }
    }

    developer.log('✅ Terminé ${sw.elapsedMilliseconds}ms');
  }

  /// 🔄 Synchronisation locale vers le remote
  Future<void> syncToRemote() async {
    final localItems = await local.getAll();
    for (final item in localItems) {
      await remote.save(item, item.id);
    }
  }

  /// 📦 Précache toutes les pièces jointes
  Future<void> precacheAllWithContext(BuildContext context) async {
    final items = await local.getAll();
    for (final item in items) {
      if (item is PieceJointe && context.mounted) {
        await HiveService.precachePieceJointe<PieceJointe>(
          context,
          T.toString(),
          item,
        );
      }
    }
  }

  /// 📡 Watch combiné (local + remote)
  Stream<List<T>> watchAllCombined() async* {
    final hiveStream = local.watchAll();
    final remoteStream = remote.watchAll();

    await for (final event in StreamGroup.merge([hiveStream, remoteStream])) {
      final Map<String, T> mergedMap = {};

      // Ajout des items locaux
      final localItems = await local.getAll();
      for (final item in localItems) {
        mergedMap[item.id] = item;
      }

      // Ajout/MAJ avec les items du remote
      for (final item in event) {
        final existing = mergedMap[item.id];
        if (existing == null ||
            (item.updatedAt != null &&
                (existing.updatedAt == null ||
                    item.updatedAt!.isAfter(existing.updatedAt!)))) {
          mergedMap[item.id] = item;
        }
      }

      yield mergedMap.values.toList();
    }
  }
}

// ============================================================================
// FACTORY POUR CRÉER LES SERVICES
// ============================================================================

class SyncServiceFactory {
  static EntitySyncService<T> create<T extends JsonModel>({
    required EntityLocalService<T> localService,
    required String collectionPath,
    required T Function(Map<String, dynamic>) fromJson,
    Query<Map<String, dynamic>> Function(dynamic)? queryBuilder,
    List<StorageMode> backends = const [StorageMode.cloudflare],
  }) {
    final firestoreService = FirestoreEntityService<T>(
      collectionPath: collectionPath,
      fromJson: fromJson,
      queryBuilder: queryBuilder,
    );

    final firebaseService = FirebaseEntityService<T>(
      fromJson: fromJson,
      collectionPath: collectionPath,
    );

    final supabaseService = SupabaseEntityService<T>(
      table: collectionPath,
      fromJson: fromJson,
    );

    final cloudFlareService = CloudflareEntityService<T>(
      collectionName: collectionPath,
      fromJson: fromJson,
    );

    final remoteService = MultiBackendRemoteService<T>(
      enabledBackends: backends,
      firestoreService: firestoreService,
      firebaseService: firebaseService,
      supabaseService: supabaseService,
      cloudflareService: cloudFlareService,
    );

    return EntitySyncService<T>(localService, remoteService);
  }
}

/// 🔁 Synchroniser toutes les entités en une seule commande
Future<void> syncAllEntitiesFromFirestore(Ref ref) async {
  final sw = Stopwatch()..start();
  developer.log('🚀 Démarrage syncAllEntities');

  final syncs = [
    ref.read(chantierSyncServiceProvider).syncFromRemote(),
    ref.read(pieceJointeSyncServiceProvider).syncFromRemote(),
    ref.read(materielSyncServiceProvider).syncFromRemote(),
    ref.read(materiauSyncServiceProvider).syncFromRemote(),
    ref.read(mainOeuvreSyncServiceProvider).syncFromRemote(),
    ref.read(techSyncServiceProvider).syncFromRemote(),
    ref.read(clientSyncServiceProvider).syncFromRemote(),
    ref.read(interventionSyncServiceProvider).syncFromRemote(),
    ref.read(pieceSyncServiceProvider).syncFromRemote(),
    ref.read(factureSyncServiceProvider).syncFromRemote(),
    ref.read(projetSyncServiceProvider).syncFromRemote(),
    ref.read(invoiceSyncServiceProvider).syncFromRemote(),
  ];

  await Future.wait(syncs);

  sw.stop();
  developer.log('✅ syncAllEntities terminé en ${sw.elapsedMilliseconds}ms');
}

/// Définit les opérations "raw" nécessaires pour une synchronisation
abstract class SyncableEntityService<T extends JsonModel>
    implements EntitySyncService<T> {
  /// Lit la version locale sous forme de Map (ex. Hive)
  @override
  Future<Map<String, dynamic>> getLocalRaw(String id);

  /// Lit la version distante (ex. Firestore)
  Future<Map<String, dynamic>> getRemoteRaw(String id);

  /// Écrit la version distante
  Future<void> saveRemoteRaw(String id, Map<String, dynamic> data);

  /// Écrit la version locale
  Future<void> saveLocalRaw(String id, Map<String, dynamic> data);
}

/// Provider générique pour construire un EntitySyncService
Provider<EntitySyncService<T>> entitySyncServiceProvider<T extends JsonModel>(
  String boxName,
  T Function(Map<String, dynamic>) fromJson,
) {
  return Provider<EntitySyncService<T>>((ref) {
    final local = HiveEntityService<T>(boxName: boxName, fromJson: fromJson);
    final remote = RemoteEntityServiceAdapter<T>(
      collection: boxName,
      fromJson: fromJson,
      storage: ref.read(remoteStorageServiceProvider),
    );
    return EntitySyncService<T>(local, remote);
  });
}
