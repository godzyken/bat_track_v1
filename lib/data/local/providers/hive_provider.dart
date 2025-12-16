import 'package:bat_track_v1/data/local/services/service_type.dart';
import 'package:bat_track_v1/features/auth/data/providers/current_user_provider.dart';
import 'package:bat_track_v1/models/providers/asynchrones/remote_service_provider.dart';
import 'package:bat_track_v1/models/services/hive_entity_service.dart';
import 'package:bat_track_v1/models/services/remote/remote_entity_service_adapter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/services/unified_entity_service.dart';
import '../../../models/services/dashboard_data_service.dart';
import '../../../models/services/entity_service_registry.dart';
import '../../../models/services/logged_entity_service.dart';
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
    buildLoggedEntityServiceProvider<Projet>(
      boxName: 'projets',
      fromJson: (json) => Projet.fromJson(json),
    ),
  );
  final chantierService = ref.watch(
    buildLoggedEntityServiceProvider<Chantier>(
      boxName: 'chantiers',
      fromJson: (json) => Chantier.fromJson(json),
    ),
  );
  final interventionService = ref.watch(
    buildLoggedEntityServiceProvider<Intervention>(
      boxName: 'interventions',
      fromJson: (json) => Intervention.fromJson(json),
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
    buildLoggedEntitySyncServiceProvider<AppUser>(
      collectionOrBoxName: 'users',
      fromJson: AppUser.fromJson,
    );

final filteredAppUserServiceProvider =
    Provider<SafeAndLoggedEntityService<AppUser>>((ref) {
      final authUser = ref.watch(currentUserProvider).value;
      final local = HiveEntityService<AppUser>(
        fromJson: (json) => AppUser.fromJson(authUser!.toJson()),
        boxName: 'users',
      );

      final remoteStorageService = ref.watch(remoteStorageServiceProvider);
      final remote = RemoteEntityServiceAdapter<AppUser>(
        fromJson: (json) => AppUser.fromJson(authUser!.toJson()),
        collection: 'users',
        storage: remoteStorageService,
      );

      final delegate = UnifiedEntityService<AppUser>(
        collectionName: local.boxName,
        remoteStorage: remote.storage,
        fromJson: local.fromJson,
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

final chantierServiceProvider = buildLoggedEntitySyncServiceProvider<Chantier>(
  collectionOrBoxName: 'chantiers',
  fromJson: (json) => Chantier.fromJson(json),
);

final clientServiceProvider = buildLoggedEntitySyncServiceProvider<Client>(
  collectionOrBoxName: 'clients',
  fromJson: (json) => Client.fromJson(json),
);
final technicienServiceProvider =
    buildLoggedEntitySyncServiceProvider<Technicien>(
      collectionOrBoxName: 'techniciens',
      fromJson: (json) => Technicien.fromJson(json),
    );
final interventionServiceProvider =
    buildLoggedEntitySyncServiceProvider<Intervention>(
      collectionOrBoxName: 'interventions',
      fromJson: (json) => Intervention.fromJson(json),
    );
final chantierEtapeServiceProvider =
    buildLoggedEntitySyncServiceProvider<ChantierEtape>(
      collectionOrBoxName: 'etapes',
      fromJson: (json) => ChantierEtape.fromJson(json),
    );
final pieceJointeServiceProvider =
    buildLoggedEntitySyncServiceProvider<PieceJointe>(
      collectionOrBoxName: 'pieceJointes',
      fromJson: (json) => PieceJointe.fromJson(json),
    );
final pieceServiceProvider = buildLoggedEntitySyncServiceProvider<Piece>(
  collectionOrBoxName: 'pieces',
  fromJson: (json) => Piece.fromJson(json),
);
final materielServiceProvider = buildLoggedEntitySyncServiceProvider<Materiel>(
  collectionOrBoxName: 'materiels',
  fromJson: (json) => Materiel.fromJson(json),
);
final materiauServiceProvider = buildLoggedEntitySyncServiceProvider<Materiau>(
  collectionOrBoxName: 'materiaux',
  fromJson: (json) => Materiau.fromJson(json),
);
final mainOeuvreServiceProvider =
    buildLoggedEntitySyncServiceProvider<MainOeuvre>(
      collectionOrBoxName: 'intervenants',
      fromJson: (json) => MainOeuvre.fromJson(json),
    );
final factureDraftServiceProvider =
    buildLoggedEntitySyncServiceProvider<FactureDraft>(
      collectionOrBoxName: 'factureDrafts',
      fromJson: (json) => FactureDraft.fromJson(json),
    );
final factureModelServiceProvider =
    buildLoggedEntitySyncServiceProvider<FactureModel>(
      collectionOrBoxName: 'factureModel',
      fromJson: (json) => FactureModel.fromJson(json),
    );
final factureServiceProvider = buildLoggedEntitySyncServiceProvider<Facture>(
  collectionOrBoxName: 'factures',
  fromJson: (json) => Facture.fromJson(json),
);
final projetServiceProvider = buildLoggedEntitySyncServiceProvider<Projet>(
  collectionOrBoxName: 'projets',
  fromJson: (json) => Projet.fromJson(json),
);
final userServiceProvider = buildLoggedEntitySyncServiceProvider<UserModel>(
  collectionOrBoxName: 'userModel',
  fromJson: (json) => UserModel.fromJson(json),
);
final equipementServiceProvider =
    buildLoggedEntitySyncServiceProvider<Equipement>(
      collectionOrBoxName: 'equipements',
      fromJson: (json) => Equipement.fromJson(json),
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
};
