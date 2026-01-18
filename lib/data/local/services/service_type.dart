import 'package:bat_track_v1/core/services/unified_entity_service_impl.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../core/services/unified_entity_service.dart';
import '../../../models/data/hive_model.dart';
import '../../../models/services/entity_service_registry.dart';
import '../../../models/services/remote/remote_storage_service.dart';
import '../../core/unified_model.dart';
import '../../remote/services/firestore_service.dart';
import '../../remote/services/storage_service.dart';
import '../models/adapters/hive_entity_factory.dart';
import '../models/entities/index_entity_extention.dart';
import '../models/index_model_extention.dart';
import 'hive_service.dart';

enum StorageMode { hive, firebase, firestore, cloudflare }

class AppConfig {
  static StorageMode storageMode = StorageMode.hive;
  static List<StorageMode> enabledBackends = [storageMode];
}

class EntityServiceFactory {
  EntityServiceFactory._(); // private constructor

  static final EntityServiceFactory instance = EntityServiceFactory._();

  /// Crée un service adapté au mode de stockage choisi
  UnifiedEntityService<M, E>
  createSyncedService<M extends UnifiedModel, E extends HiveModel<M>>({
    required String collectionName,
    required HiveEntityFactory<M, E> factory,
    required RemoteStorageService remoteStorageService,
  }) {
    final baseService = UnifiedEntityServiceImpl<M, E>(
      collectionName: collectionName,
      factory: factory,
      remoteStorage: remoteStorageService,
    );

    return baseService;
  }
}

final chantierService = buildEntityServiceProvider<Chantier, ChantierEntity>(
  collectionOrBoxName: 'chantiers',
  factory: ChantierEntityFactory(),
);

final clientService = buildEntityServiceProvider<Client, ClientEntity>(
  collectionOrBoxName: 'clients',
  factory: ClientEntityFactory(),
);
final technicienService =
    buildEntityServiceProvider<Technicien, TechnicienEntity>(
      collectionOrBoxName: 'techniciens',
      factory: TechnicienEntityFactory(),
    );
final interventionService =
    buildEntityServiceProvider<Intervention, InterventionEntity>(
      collectionOrBoxName: 'interventions',
      factory: InterventionEntityFactory(),
    );
final chantierEtapeService =
    buildEntityServiceProvider<ChantierEtape, ChantierEtapesEntity>(
      collectionOrBoxName: 'chantierEtapes',
      factory: ChantierEtapeEntityFactory(),
    );
final pieceJointeService =
    buildEntityServiceProvider<PieceJointe, PieceJointeEntity>(
      collectionOrBoxName: 'piecesJointes',
      factory: PieceJointeEntityFactory(),
    );
final pieceService = buildEntityServiceProvider<Piece, PieceEntity>(
  collectionOrBoxName: 'pieces',
  factory: PieceEntityFactory(),
);
final materielService = buildEntityServiceProvider<Materiel, MaterielEntity>(
  collectionOrBoxName: 'materiels',
  factory: MaterielEntityFactory(),
);
final materiauService = buildEntityServiceProvider<Materiau, MateriauEntity>(
  collectionOrBoxName: 'materiau',
  factory: MateriauEntityFactory(),
);
final mainOeuvreService =
    buildEntityServiceProvider<MainOeuvre, MainOeuvreEntity>(
      collectionOrBoxName: 'mainOeuvre',
      factory: MainOeuvreEntityFactory(),
    );
final projetService = buildEntityServiceProvider<Projet, ProjetEntity>(
  collectionOrBoxName: 'projets',
  factory: ProjetEntityFactory(),
);
final factureService = buildEntityServiceProvider<Facture, FactureEntity>(
  collectionOrBoxName: 'factures',
  factory: FactureEntityFactory(),
);
final factureModelService =
    buildEntityServiceProvider<FactureModel, FactureModelEntity>(
      collectionOrBoxName: 'factureModels',
      factory: FactureModelEntityFactory(),
    );
final factureDraftService =
    buildEntityServiceProvider<FactureDraft, FactureDraftEntity>(
      collectionOrBoxName: 'factureDrafts',
      factory: FactureDraftEntityFactory(),
    );
final userService = buildEntityServiceProvider<UserModel, UserEntity>(
  collectionOrBoxName: 'users',
  factory: UserEntityFactory(),
);
final equipementService =
    buildEntityServiceProvider<Equipement, EquipementEntity>(
      collectionOrBoxName: 'equipements',
      factory: EquipementEntityFactory(),
    );

final storageService = StorageService(FirebaseStorage.instance);
final firebaseService = FirestoreService();

extension EntityServicesFilters<M extends UnifiedModel, E extends HiveModel<M>>
    on UnifiedEntityService<M, E> {
  /// Observe tous les items liés à un technicien spécifique
  Stream<List<M>> watchByTechnicien(String technicienId) async* {
    final box = await HiveService.box<M>(collectionName);
    yield* box.watch().asyncMap((_) async {
      final allItems = await getAllRemote();
      return allItems.where((item) {
        final json = item.toJson();
        return json['technicienId'] == technicienId;
      }).toList();
    });
  }

  /// Observe tous les items appartenant à un propriétaire spécifique
  Stream<List<M>> watchByOwner(String ownerId) async* {
    final box = await HiveService.box<M>(collectionName);
    yield* box.watch().asyncMap((_) async {
      final allItems = await getAllLocal();
      return allItems.where((item) {
        final json = item.toJson();
        return json['clientId'] == ownerId;
      }).toList();
    });
  }

  /// Observe tous les items liés à un projet spécifique
  Stream<List<M>> watchByProjects(String projectId) async* {
    final box = await HiveService.box<M>(collectionName);
    yield* box.watch().asyncMap((_) async {
      final allItems = await getAllRemote();
      return allItems.where((item) {
        final json = item.toJson();
        return json['id'] == projectId;
      }).toList();
    });
  }

  /// Observe tous les items d'un propriétaire dans un projet spécifique
  Stream<List<M>> watchByOwnerProjects(
    String ownerId,
    String projectId,
  ) async* {
    final box = await HiveService.box<M>(collectionName);
    yield* box.watch().asyncMap((_) async {
      final allItems = await getAllRemote();
      return allItems.where((item) {
        final json = item.toJson();
        return json['clientId'] == ownerId && json['id'] == projectId;
      }).toList();
    });
  }
}
