import 'package:bat_track_v1/core/services/unified_entity_service_impl.dart';
import 'package:bat_track_v1/data/local/models/adapters/hive_entity_factory.dart';
import 'package:bat_track_v1/data/local/models/entities/index_entity_extention.dart';
import 'package:bat_track_v1/data/local/services/service_type.dart';
import 'package:bat_track_v1/features/auth/data/providers/current_user_provider.dart';
import 'package:bat_track_v1/models/services/hive_entity_service.dart';
import 'package:bat_track_v1/models/services/remote/remote_entity_service_adapter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_models/shared_models.dart';

import '../../../models/services/dashboard_data_service.dart';
import '../../../models/services/entity_service_registry.dart';
import '../../../models/services/logged_entity_service.dart';
import '../../remote/providers/chantier_provider.dart';
import '../../remote/providers/multi_backend_remote_provider.dart';
import '../models/index_model_extention.dart';
import '../services/hive_service.dart';

final hiveInitProvider = FutureProvider<void>((ref) async {
  await HiveService.init();
});

final hiveDirectoryProvider = FutureProvider<void>((ref) async {
  final dir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(dir.path);
});

////Providers box for CRUD Operations

////Liste tout les hiveProvider list
final allProjectsProvider = StreamProvider.autoDispose<List<Projet>>((ref) {
  final service = ref.watch(projetServiceProvider);
  return service.watchAll();
});

final allChantiersStreamProvider = StreamProvider.autoDispose<List<Chantier>>((
  ref,
) {
  final service = ref.watch(chantierServiceProvider);
  return service.watchAll();
});

final allEtapesStreamProvider = StreamProvider.autoDispose<List<ChantierEtape>>(
  (ref) {
    final service = ref.watch(chantierEtapeServiceProvider);
    return service.watchAll();
  },
);

final allTechniciensStreamProvider =
    StreamProvider.autoDispose<List<Technicien>>((ref) {
      final service = ref.watch(technicienServiceProvider);
      return service.watchAll();
    });

final allUsersStreamProvider = StreamProvider.autoDispose<List<AppUser>>((ref) {
  final service = ref.watch(appUserEntityServiceProvider);
  return service.watchAll();
});

final allEquipementsStreamProvider =
    StreamProvider.autoDispose<List<Equipement>>((ref) {
      final service = ref.watch(equipementServiceProvider);
      return service.watchAll();
    });

final allClientsStreamProvider = StreamProvider.autoDispose<List<Client>>((
  ref,
) {
  final service = ref.watch(clientServiceProvider);
  return service.watchAll();
});

final allPiecesStreamProvider = StreamProvider.autoDispose<List<Piece>>((ref) {
  final service = ref.watch(pieceServiceProvider);
  return service.watchAll();
});

final allInterventionsStreamProvider =
    StreamProvider.autoDispose<List<Intervention>>((ref) {
      final service = ref.watch(interventionServiceProvider);
      return service.watchAll();
    });

final allMaterielsStreamProvider = StreamProvider.autoDispose<List<Materiel>>((
  ref,
) {
  final service = ref.watch(materielServiceProvider);
  return service.watchAll();
});

final allFacturesDraftStreamProvider =
    StreamProvider.autoDispose<List<FactureDraft>>((ref) {
      final service = ref.watch(factureDraftServiceProvider);
      return service.watchAll();
    });

final allFacturesModelStreamProvider =
    StreamProvider.autoDispose<List<FactureModel>>((ref) {
      final service = ref.watch(factureModelServiceProvider);
      return service.watchAll();
    });

final allFacturesStreamProvider = StreamProvider.autoDispose
    .family<List<Facture>, String>((ref, chantierId) {
      final service = ref.watch(factureServiceProvider);
      return service.watchByProjects(chantierId);
    });

final allMateriauxStreamProvider = StreamProvider.autoDispose<List<Materiau>>((
  ref,
) {
  final service = ref.watch(materiauServiceProvider);
  return service.watchAll();
});

final allMainOeuvresStreamProvider =
    StreamProvider.autoDispose<List<MainOeuvre>>((ref) {
      final service = ref.watch(mainOeuvreServiceProvider);
      return service.watchAll();
    });

////Services for CRUD Operations
final dashboardServiceProvider = Provider.family<DashboardService, AppUser>((
  ref,
  user,
) {
  final projetService = ref.watch(
    buildLoggedEntityServiceProvider<Projet, ProjetEntity>(
      boxName: 'projets',
      factory: ProjetEntityFactory(),
    ),
  );
  final chantierService = ref.watch(
    buildLoggedEntityServiceProvider<Chantier, ChantierEntity>(
      boxName: 'chantiers',
      factory: ChantierEntityFactory(),
    ),
  );
  final interventionService = ref.watch(
    buildLoggedEntityServiceProvider<Intervention, InterventionEntity>(
      boxName: 'interventions',
      factory: InterventionEntityFactory(),
    ),
  );

  return DashboardService(
    user: user,
    projetService: projetService,
    chantierService: chantierService,
    interventionService: interventionService,
  );
});

final appUserEntityServiceProvider =
    buildLoggedEntitySyncServiceProvider<AppUser, AppUserEntity>(
      collectionName: 'users',
      factory: AppUserEntityFactory(),
    );

final filteredAppUserServiceProvider =
    Provider<SafeAndLoggedEntityService<AppUser, AppUserEntity>>((ref) {
      final authUser = ref.watch(currentUserProvider).value;
      final local = HiveEntityService<AppUser>(
        fromJson: (json) => AppUser.fromJson(authUser!.toJson()),
        boxName: 'users',
      );

      final remoteStorageService = ref.watch(multiBackendRemoteProvider);
      final remote = RemoteEntityServiceAdapter<AppUser>(
        fromJson: (json) => AppUser.fromJson(authUser!.toJson()),
        collection: 'users',
        storage: remoteStorageService,
      );

      final delegate = UnifiedEntityServiceImpl<AppUser, AppUserEntity>(
        collectionName: local.boxName,
        remoteStorage: remote.storage,
        factory: AppUserEntityFactory(),
      );
      return SafeAndLoggedEntityService(delegate, ref);
    });

/*
*
*  watch entity providers
*
* */

final watchTechnicienProvider = StreamProvider.autoDispose
    .family<Technicien?, String>((ref, id) {
      final service = ref.watch(technicienServiceProvider);
      return service.watch(id);
    });

final watchPiecesByChantierProvider = StreamProvider.autoDispose
    .family<List<Piece>, String>((ref, chantierId) {
      final service = ref.watch(pieceServiceProvider);
      return service.watchByProjects(chantierId);
    });

/*
*
*  buildLoggedEntitySyncServiceProvider
*
* */

final clientServiceProvider =
    buildLoggedEntitySyncServiceProvider<Client, ClientEntity>(
      collectionName: 'clients',
      factory: ClientEntityFactory(),
    );

final technicienServiceProvider =
    buildLoggedEntitySyncServiceProvider<Technicien, TechnicienEntity>(
      collectionName: 'techniciens',
      factory: TechnicienEntityFactory(),
    );

final interventionServiceProvider =
    buildLoggedEntitySyncServiceProvider<Intervention, InterventionEntity>(
      collectionName: 'interventions',
      factory: InterventionEntityFactory(),
    );

final chantierEtapeServiceProvider =
    buildLoggedEntitySyncServiceProvider<ChantierEtape, ChantierEtapesEntity>(
      collectionName: 'etapes',
      factory: ChantierEtapeEntityFactory(),
    );

final pieceJointeServiceProvider =
    buildLoggedEntitySyncServiceProvider<PieceJointe, PieceJointeEntity>(
      collectionName: 'pieceJointes',
      factory: PieceJointeEntityFactory(),
    );

final pieceServiceProvider =
    buildLoggedEntitySyncServiceProvider<Piece, PieceEntity>(
      collectionName: 'pieces',
      factory: PieceEntityFactory(),
    );

final materielServiceProvider =
    buildLoggedEntitySyncServiceProvider<Materiel, MaterielEntity>(
      collectionName: 'materiels',
      factory: MaterielEntityFactory(),
    );

final materiauServiceProvider =
    buildLoggedEntitySyncServiceProvider<Materiau, MateriauEntity>(
      collectionName: 'materiaux',
      factory: MateriauEntityFactory(),
    );

final mainOeuvreServiceProvider =
    buildLoggedEntitySyncServiceProvider<MainOeuvre, MainOeuvreEntity>(
      collectionName: 'intervenants',
      factory: MainOeuvreEntityFactory(),
    );

final factureDraftServiceProvider =
    buildLoggedEntitySyncServiceProvider<FactureDraft, FactureDraftEntity>(
      collectionName: 'factureDrafts',
      factory: FactureDraftEntityFactory(),
    );

final factureModelServiceProvider =
    buildLoggedEntitySyncServiceProvider<FactureModel, FactureModelEntity>(
      collectionName: 'factureModel',
      factory: FactureModelEntityFactory(),
    );

final factureServiceProvider =
    buildLoggedEntitySyncServiceProvider<Facture, FactureEntity>(
      collectionName: 'factures',
      factory: FactureEntityFactory(),
    );

final projetServiceProvider =
    buildLoggedEntitySyncServiceProvider<Projet, ProjetEntity>(
      collectionName: 'projets',
      factory: ProjetEntityFactory(),
    );

final userServiceProvider =
    buildLoggedEntitySyncServiceProvider<UserModel, UserEntity>(
      collectionName: 'userModel',
      factory: UserEntityFactory(),
    );

final equipementServiceProvider =
    buildLoggedEntitySyncServiceProvider<Equipement, EquipementEntity>(
      collectionName: 'equipements',
      factory: EquipementEntityFactory(),
    );

final _serviceRegistry = <Type, ProviderBase>{
  Chantier: chantierServiceProvider,
  Client: clientServiceProvider,
  Technicien: technicienServiceProvider,
  Intervention: interventionServiceProvider,
  ChantierEtape: chantierEtapeServiceProvider,
  PieceJointe: pieceJointeServiceProvider,
  Piece: pieceServiceProvider,
  Materiel: materielServiceProvider,
  Materiau: materiauServiceProvider,
  MainOeuvre: mainOeuvreServiceProvider,
  FactureDraft: factureDraftServiceProvider,
  FactureModel: factureModelServiceProvider,
  Facture: factureServiceProvider,
  Projet: projetServiceProvider,
  UserModel: userServiceProvider,
  Equipement: equipementServiceProvider,
  AppUser: appUserEntityServiceProvider,

  // AppUser: filteredAppUserServiceProvider,
};
