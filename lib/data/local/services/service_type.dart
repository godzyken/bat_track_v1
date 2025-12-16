import 'package:bat_track_v1/models/services/firestore_entity_service.dart';
import 'package:bat_track_v1/models/services/multi_backend_remote_service.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../core/services/unified_entity_service.dart';
import '../../../models/providers/adapter/hive_remote_storage_wrapper.dart';
import '../../../models/services/cloud_flare_entity_service.dart';
import '../../../models/services/entity_service_registry.dart';
import '../../../models/services/firebase_entity_service.dart';
import '../../core/unified_model.dart';
import '../../remote/services/firestore_service.dart';
import '../../remote/services/storage_service.dart';
import '../models/index_model_extention.dart';
import 'hive_service.dart';

enum StorageMode { hive, firebase, firestore, cloudflare }

class AppConfig {
  static StorageMode storageMode = StorageMode.hive;
  static List<StorageMode> enabledBackends = [storageMode];
}

/*mixin StorageHandlerMixin<T extends UnifiedModel> on Object {
  String get boxName;

  StorageMode get storageMode => AppConfig.storageMode;

  StorageService get storage => StorageService(FirebaseStorage.instance);

  Future<void> put(String id, T item) async {
    switch (storageMode) {
      case StorageMode.hive:
        await HiveService.put<T>(boxName, id, item);
        break;
      case StorageMode.firebase:
      case StorageMode.firestore:
      case StorageMode.cloudflare:
        if (item is HasFile) {
          developer.log('[ITEM] message :${item.toJson()}');
          final file = (item as HasFile).getFile();
          final path = '$boxName/$id/${file.path.split('/').last}';
          await storage.uploadFile(file, path);
        }
        await FirestoreService.setData<T>(
          collectionPath: boxName,
          docId: id,
          data: item,
        );
        break;
      case StorageMode.supabase:
        throw UnimplementedError('Supabase not yet implemented');
    }
  }

  Future<void> remove(String id) async {
    switch (storageMode) {
      case StorageMode.hive:
        await HiveService.delete<T>(boxName, id);
        break;
      case StorageMode.firebase:
      case StorageMode.firestore:
      case StorageMode.cloudflare:
        await FirestoreService.deleteData(collectionPath: boxName, docId: id);
        break;
      case StorageMode.supabase:
        await SupabaseService.instance.deleteRaw(boxName, id);
        break;
    }
  }

  Future<List<T>> fetchAll({T Function(Map<String, dynamic>)? fromJson}) async {
    switch (storageMode) {
      case StorageMode.hive:
        return HiveService.getAll<T>(boxName);
      case StorageMode.firebase:
      case StorageMode.firestore:
      case StorageMode.cloudflare:
        return FirestoreService.getAll<T>(
          collectionPath: boxName,
          fromJson: fromJson!,
        );
      case StorageMode.supabase:
        return SupabaseService.instance.getAll<T>(boxName, fromJson!);
    }
  }
}*/

class EntityServiceFactory {
  EntityServiceFactory._(); // private constructor

  static final EntityServiceFactory instance = EntityServiceFactory._();

  /// Crée un service adapté au mode de stockage choisi
  UnifiedEntityService<T> create<T extends UnifiedModel>({
    required String boxNameOrCollectionName,
    required T Function(Map<String, dynamic>) fromJson,
    String? supabaseTable,
  }) {
    switch (AppConfig.storageMode) {
      case StorageMode.hive:
      case StorageMode.firestore:
      case StorageMode.firebase:
      case StorageMode.cloudflare:
        // Définir les backends activés à partir de AppConfig

        final multiBackend = MultiBackendRemoteService<T>(
          enabledBackends: AppConfig.enabledBackends,
          firestoreService: FirestoreEntityService(
            collectionPath: boxNameOrCollectionName,
            fromJson: fromJson,
          ),
          firebaseService: FirebaseEntityService(
            collectionPath: boxNameOrCollectionName,
            fromJson: fromJson,
          ),
          cloudflareService: CloudflareEntityService(
            collectionName: boxNameOrCollectionName,
            fromJson: fromJson,
          ),
        );

        final remoteStorageWrapper = HiveRemoteStorageWrapper<T>(
          multiBackend: multiBackend,
        );

        return UnifiedEntityService<T>(
          collectionName: boxNameOrCollectionName,
          fromJson: fromJson,
          remoteStorage: remoteStorageWrapper,
        );
    }
  }
}

final chantierService = buildEntityServiceProvider<Chantier>(
  collectionOrBoxName: 'chantiers',
  fromJson: Chantier.fromJson,
);

final clientService = buildEntityServiceProvider<Client>(
  collectionOrBoxName: 'clients',
  fromJson: Client.fromJson,
);
final technicienService = buildEntityServiceProvider<Technicien>(
  collectionOrBoxName: 'techniciens',
  fromJson: Technicien.fromJson,
);
final interventionService = buildEntityServiceProvider<Intervention>(
  collectionOrBoxName: 'interventions',
  fromJson: Intervention.fromJson,
);
final chantierEtapeService = buildEntityServiceProvider<ChantierEtape>(
  collectionOrBoxName: 'chantierEtapes',
  fromJson: ChantierEtape.fromJson,
);
final pieceJointeService = buildEntityServiceProvider<PieceJointe>(
  collectionOrBoxName: 'piecesJointes',
  fromJson: PieceJointe.fromJson,
);
final pieceService = buildEntityServiceProvider<Piece>(
  collectionOrBoxName: 'pieces',
  fromJson: Piece.fromJson,
);
final materielService = buildEntityServiceProvider<Materiel>(
  collectionOrBoxName: 'materiels',
  fromJson: Materiel.fromJson,
);
final materiauService = buildEntityServiceProvider<Materiau>(
  collectionOrBoxName: 'materiau',
  fromJson: Materiau.fromJson,
);
final mainOeuvreService = buildEntityServiceProvider<MainOeuvre>(
  collectionOrBoxName: 'mainOeuvre',
  fromJson: MainOeuvre.fromJson,
);
final projetService = buildEntityServiceProvider<Projet>(
  collectionOrBoxName: 'projets',
  fromJson: Projet.fromJson,
);
final factureService = buildEntityServiceProvider<Facture>(
  collectionOrBoxName: 'factures',
  fromJson: Facture.fromJson,
);
final factureModelService = buildEntityServiceProvider<FactureModel>(
  collectionOrBoxName: 'factureModels',
  fromJson: FactureModel.fromJson,
);
final factureDraftService = buildEntityServiceProvider<FactureDraft>(
  collectionOrBoxName: 'factureDrafts',
  fromJson: FactureDraft.fromJson,
);
final userService = buildEntityServiceProvider<UserModel>(
  collectionOrBoxName: 'users',
  fromJson: UserModel.fromJson,
);
final equipementService = buildEntityServiceProvider<Equipement>(
  collectionOrBoxName: 'equipements',
  fromJson: Equipement.fromJson,
);

final storageService = StorageService(FirebaseStorage.instance);
final firebaseService = FirestoreService();

extension EntityServicesFilters<T extends UnifiedModel>
    on UnifiedEntityService<T> {
  /// Observe tous les items liés à un technicien spécifique
  Stream<List<T>> watchByTechnicien(String technicienId) async* {
    final box = await HiveService.box<T>(collectionName);
    yield* box.watch().asyncMap((_) async {
      final allItems = await getAllRemote();
      return allItems.where((item) {
        final json = item.toJson();
        return json['technicienId'] == technicienId;
      }).toList();
    });
  }

  /// Observe tous les items appartenant à un propriétaire spécifique
  Stream<List<T>> watchByOwner(String ownerId) async* {
    final box = await HiveService.box<T>(collectionName);
    yield* box.watch().asyncMap((_) async {
      final allItems = await getAllLocal();
      return allItems.where((item) {
        final json = item.toJson();
        return json['clientId'] == ownerId;
      }).toList();
    });
  }

  /// Observe tous les items liés à un projet spécifique
  Stream<List<T>> watchByProjects(String projectId) async* {
    final box = await HiveService.box<T>(collectionName);
    yield* box.watch().asyncMap((_) async {
      final allItems = await getAllRemote();
      return allItems.where((item) {
        final json = item.toJson();
        return json['id'] == projectId;
      }).toList();
    });
  }

  /// Observe tous les items d'un propriétaire dans un projet spécifique
  Stream<List<T>> watchByOwnerProjects(
    String ownerId,
    String projectId,
  ) async* {
    final box = await HiveService.box<T>(collectionName);
    yield* box.watch().asyncMap((_) async {
      final allItems = await getAllRemote();
      return allItems.where((item) {
        final json = item.toJson();
        return json['clientId'] == ownerId && json['id'] == projectId;
      }).toList();
    });
  }
}
