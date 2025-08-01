import 'package:bat_track_v1/models/services/firestore_entity_service.dart';
import 'package:bat_track_v1/models/services/logged_entity_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';

import '../../../models/data/json_model.dart';
import '../../../models/notifiers/entity_notifier_provider.dart';
import '../../../models/services/entity_service.dart';
import '../models/index_model_extention.dart';
import '../services/hive_service.dart';
import '../services/service_type.dart';

final hiveInitProvider = FutureProvider<void>((ref) async {
  await HiveService.init();
});

final hiveDirectoryProvider = FutureProvider<void>((ref) async {
  final dir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(dir.path);
});

////Providers box for CRUD Operations

final chantierBoxProvider = Provider<Box<Chantier>>(
  (ref) => Hive.box<Chantier>('chantiers'),
);
final clientBoxProvider = Provider<Box<Client>>(
  (ref) => Hive.box<Client>('clients'),
);
final technicienBoxProvider = Provider<Box<Technicien>>(
  (ref) => Hive.box<Technicien>('techniciens'),
);
final interventionBoxProvider = Provider<Box<Intervention>>(
  (ref) => Hive.box<Intervention>('interventions'),
);
final chantierEtapeBoxProvider = Provider(
  (ref) async => await Hive.openBox<ChantierEtape>('chantierEtapes'),
);
final pieceJointeBoxProvider = Provider<Box<PieceJointe>>(
  (ref) => Hive.box<PieceJointe>('piecesJointes'),
);
final pieceBoxProvider = Provider<Box<Piece>>(
  (ref) => Hive.box<Piece>('pieces'),
);
final materielBoxProvider = Provider<Box<Materiel>>(
  (ref) => Hive.box<Materiel>('materiels'),
);
final materiauBoxProvider = Provider<Box<Materiau>>(
  (ref) => Hive.box<Materiau>('materiau'),
);
final mainOeuvreBoxProvider = Provider<Box<MainOeuvre>>(
  (ref) => Hive.box<MainOeuvre>('mainOeuvre'),
);
final factureDraftBoxProvider = Provider<Box<FactureDraft>>(
  (ref) => Hive.box<FactureDraft>('factureDraft'),
);
final factureModelBoxProvider = Provider<Box<FactureModel>>(
  (ref) => Hive.box<FactureModel>('FactureModel'),
);
final factureBoxProvider = Provider<Box<Facture>>(
  (ref) => Hive.box<Facture>('facture'),
);
final projetBoxProvider = Provider<Box<Projet>>(
  (ref) => Hive.box<Projet>('projet'),
);
final userBoxProvider = Provider<Box<UserModel>>(
  (ref) => Hive.box<UserModel>('UserModel'),
);
final equipementBoxProvider = Provider<Box<Equipement>>(
  (ref) => Hive.box<Equipement>('Equipement'),
);

////Providers Family for CRUD Operations

final chantierProvider = Provider.family<Chantier?, String>((ref, id) {
  final box = Hive.box<Chantier>('chantiers');
  return box.get(id);
});
final clientProvider = Provider.family<Client?, String>((ref, id) {
  final box = Hive.box<Client>('clients');
  return box.get(id);
});
final technicienProvider = Provider.family<Technicien?, String>((ref, id) {
  final box = Hive.box<Technicien>('techniciens');
  return box.get(id);
});
final interventionProvider = Provider.family<Intervention?, String>((ref, id) {
  final box = Hive.box<Intervention>('interventions');
  return box.get(id);
});
final chantierEtapesListFutureProvider =
    FutureProvider.family<List<ChantierEtape>, String>((ref, chantierId) async {
      final box = await ref.watch(chantierEtapeBoxProvider);
      return box.values.where((e) => e.id == chantierId).toList();
    });

final pieceJointeProvider = Provider.family<PieceJointe?, String>((ref, id) {
  final box = Hive.box<PieceJointe>('piecesJointes');
  return box.get(id);
});
final pieceProvider = Provider.family<Piece?, String>((ref, id) {
  final box = Hive.box<Piece>('pieces');
  return box.get(id);
});
final materielProvider = Provider.family<Materiel?, String>((ref, id) {
  final box = Hive.box<Materiel>('materiels');
  return box.get(id);
});
final materiauProvider = Provider.family<Materiau?, String>((ref, id) {
  final box = Hive.box<Materiau>('materiau');
  return box.get(id);
});
final mainOeuvreProvider = Provider.family<MainOeuvre?, String>((ref, id) {
  final box = Hive.box<MainOeuvre>('mainOeuvre');
  return box.get(id);
});

final factureDraftProvider = Provider.family<FactureDraft?, String>((ref, id) {
  final box = Hive.box<FactureDraft>('factureDraft');
  return box.get(id);
});

final factureModelProvider = Provider.family<FactureModel?, String>((ref, id) {
  final box = Hive.box<FactureModel>('factureModel');
  return box.get(id);
});

final factureProvider = Provider.family<Facture?, String>((ref, id) {
  final box = Hive.box<Facture>('facture');
  return box.get(id);
});

final projetProvider = Provider.family<Projet?, String>((ref, id) {
  final box = Hive.box<Projet>('projet');
  return box.get(id);
});

final userProvider = Provider.family<UserModel?, String>((ref, id) {
  final box = Hive.box<UserModel>('user');
  return box.get(id);
});

final equipementProvider = Provider.family<Equipement?, String>((ref, id) {
  final box = Hive.box<Equipement>('equipement');
  return box.get(id);
});

////Liste tout les hiveProvider list
final allProjectsProvider = Provider<List<Projet>>((ref) {
  final box = Hive.box<Projet>('projets');
  return box.values.toList();
});

final allChantiersProvider = Provider<List<Chantier>>((ref) {
  final box = Hive.box<Chantier>('chantiers');
  return box.values.toList();
});

final allEtapesProvider = Provider<List<ChantierEtape>>((ref) {
  final box = Hive.box<ChantierEtape>('chantier_etapes');
  return box.values.toList();
});

final allTechniciensProvider = Provider<List<Technicien>>((ref) {
  final box = Hive.box<Technicien>('technicien');
  return box.values.toList();
});

final allUsersProvider = Provider<List<UserModel>>((ref) {
  final box = Hive.box<UserModel>('user');
  return box.values.toList();
});

final allEquipementsProvider = Provider<List<Equipement>>((ref) {
  final box = Hive.box<Equipement>('equipement');
  return box.values.toList();
});

final allInterventionsProvider = Provider<List<Intervention>>((ref) {
  final box = Hive.box<Intervention>('interventions');
  return box.values.toList();
});

////Services for CRUD Operations
final chantierServiceProvider = Provider<EntityService<Chantier>>(
  (ref) => LoggedEntityService<Chantier>(
    FirestoreEntityService<Chantier>(
      collectionPath: 'chantiers',
      fromJson: (json) => Chantier.fromJson(json),
    ),
    ref,
  ),
);
final clientServiceProvider = Provider<EntityService<Client>>(
  (ref) => LoggedEntityService<Client>(
    FirestoreEntityService<Client>(
      collectionPath: 'clients',
      fromJson: (json) => Client.fromJson(json),
    ),
    ref,
  ),
);
final technicienServiceProvider = Provider<EntityService<Technicien>>(
  (ref) => LoggedEntityService<Technicien>(
    FirestoreEntityService<Technicien>(
      collectionPath: 'techniciens',
      fromJson: (json) => Technicien.fromJson(json),
    ),
    ref,
  ),
);
final interventionServiceProvider = Provider<EntityService<Intervention>>(
  (ref) => LoggedEntityService<Intervention>(
    FirestoreEntityService<Intervention>(
      collectionPath: 'interventions',
      fromJson: (json) => Intervention.fromJson(json),
    ),
    ref,
  ),
);
final chantierEtapeServiceProvider = Provider<EntityService<ChantierEtape>>(
  (ref) => LoggedEntityService<ChantierEtape>(
    FirestoreEntityService<ChantierEtape>(
      collectionPath: 'etapes',
      fromJson: (json) => ChantierEtape.fromJson(json),
    ),
    ref,
  ),
);

final pieceJointeServiceProvider = Provider<EntityService<PieceJointe>>(
  (ref) => LoggedEntityService<PieceJointe>(
    FirestoreEntityService<PieceJointe>(
      collectionPath: 'pieceJointes',
      fromJson: (json) => PieceJointe.fromJson(json),
    ),
    ref,
  ),
);
final pieceServiceProvider = Provider<EntityService<Piece>>(
  (ref) => LoggedEntityService<Piece>(
    FirestoreEntityService<Piece>(
      collectionPath: 'pieces',
      fromJson: (json) => Piece.fromJson(json),
    ),
    ref,
  ),
);
final materielServiceProvider = Provider<EntityService<Materiel>>(
  (ref) => LoggedEntityService<Materiel>(
    FirestoreEntityService<Materiel>(
      collectionPath: 'materiels',
      fromJson: (json) => Materiel.fromJson(json),
    ),
    ref,
  ),
);
final materiauServiceProvider = Provider<EntityService<Materiau>>(
  (ref) => LoggedEntityService<Materiau>(
    FirestoreEntityService<Materiau>(
      collectionPath: 'materiaux',
      fromJson: (json) => Materiau.fromJson(json),
    ),
    ref,
  ),
);
final mainOeuvreServiceProvider = Provider<EntityService<MainOeuvre>>(
  (ref) => LoggedEntityService<MainOeuvre>(
    FirestoreEntityService<MainOeuvre>(
      collectionPath: 'intervenants',
      fromJson: (json) => MainOeuvre.fromJson(json),
    ),
    ref,
  ),
);
final factureDraftServiceProvider = Provider<EntityService<FactureDraft>>(
  (ref) => LoggedEntityService<FactureDraft>(
    FirestoreEntityService<FactureDraft>(
      collectionPath: 'factureDrafts',
      fromJson: (json) => FactureDraft.fromJson(json),
    ),
    ref,
  ),
);
final factureModelServiceProvider = Provider<EntityService<FactureModel>>(
  (ref) => LoggedEntityService<FactureModel>(
    FirestoreEntityService<FactureModel>(
      collectionPath: 'factureModel',
      fromJson: (json) => FactureModel.fromJson(json),
    ),
    ref,
  ),
);
final factureServiceProvider = Provider<EntityService<Facture>>(
  (ref) => LoggedEntityService<Facture>(
    FirestoreEntityService<Facture>(
      collectionPath: 'factures',
      fromJson: (json) => Facture.fromJson(json),
    ),
    ref,
  ),
);
final projetServiceProvider = Provider<EntityService<Projet>>(
  (ref) => LoggedEntityService<Projet>(
    FirestoreEntityService<Projet>(
      collectionPath: 'projets',
      fromJson: (json) => Projet.fromJson(json),
    ),
    ref,
  ),
);
final userServiceProvider = Provider<EntityService<UserModel>>(
  (ref) => LoggedEntityService<UserModel>(
    FirestoreEntityService<UserModel>(
      collectionPath: 'userModel',
      fromJson: (json) => UserModel.fromJson(json),
    ),
    ref,
  ),
);
final equipementServiceProvider = Provider<EntityService<Equipement>>(
  (ref) => LoggedEntityService<Equipement>(
    FirestoreEntityService<Equipement>(
      collectionPath: 'equipements',
      fromJson: (json) => Equipement.fromJson(json),
    ),
    ref,
  ),
);

////Providers for EntityServices
Provider<EntityServices<T>> entityServiceProvider<T extends JsonModel>() {
  return Provider<EntityServices<T>>((ref) {
    final provider = _serviceRegistry[T];
    if (provider == null) {
      throw UnimplementedError('No service registered for $T');
    }
    return ref.watch(provider) as EntityServices<T>;
  });
}

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

// Déclaration simplifiée du provider Chantier
final chantierNotifierProvider = createEntityNotifierProvider<Chantier>(
  hiveBoxName: 'chantiers',
  service: chantierService,
);

// Pareil pour Client, Technicien, etc.
final clientNotifierProvider = createEntityNotifierProvider<Client>(
  hiveBoxName: 'clients',
  service: clientService,
);

final technicienNotifierProvider = createEntityNotifierProvider<Technicien>(
  hiveBoxName: 'techniciens',
  service: technicienService,
);

final interventionNotifierProvider = createEntityNotifierProvider<Intervention>(
  hiveBoxName: 'interventions',
  service: interventionService,
);

final chantierEtapeNotifierProvider =
    createEntityNotifierProvider<ChantierEtape>(
      hiveBoxName: 'chantierEtapes',
      service: chantierEtapeService,
    );

final pieceJointeNotifierProvider = createEntityNotifierProvider<PieceJointe>(
  hiveBoxName: 'piecesJointes',
  service: pieceJointeService,
);

final pieceNotifierProvider = createEntityNotifierProvider<Piece>(
  hiveBoxName: 'pieces',
  service: pieceService,
);

final materielNotifierProvider = createEntityNotifierProvider<Materiel>(
  hiveBoxName: 'materiels',
  service: materielService,
);

final materiauNotifierProvider = createEntityNotifierProvider<Materiau>(
  hiveBoxName: 'materiau',
  service: materiauService,
);

final mainOeuvreNotifierProvider = createEntityNotifierProvider<MainOeuvre>(
  hiveBoxName: 'mainOeuvre',
  service: mainOeuvreService,
);

final projetNotifierProvider = createEntityNotifierProvider<Projet>(
  hiveBoxName: 'projet',
  service: projetService,
);

final factureNotifierProvider = createEntityNotifierProvider<Facture>(
  hiveBoxName: 'factures',
  service: factureService,
);
final factureDraftNotifierProvider = createEntityNotifierProvider<FactureDraft>(
  hiveBoxName: 'factureDrafts',
  service: factureDraftService,
);
final factureModelNotifierProvider = createEntityNotifierProvider<FactureModel>(
  hiveBoxName: 'factureModels',
  service: factureModelService,
);
final userNotifierProvider = createEntityNotifierProvider<UserModel>(
  hiveBoxName: 'user',
  service: userService,
);
final equipementNotifierProvider = createEntityNotifierProvider<Equipement>(
  hiveBoxName: 'equipement',
  service: equipementService,
);
