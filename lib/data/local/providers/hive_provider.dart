import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../../models/data/json_model.dart';
import '../../../models/notifiers/entity_notifier_provider.dart';
import '../models/index_model_extention.dart';
import '../services/hive_service.dart';
import '../services/service_type.dart';

final hiveInitProvider = FutureProvider<void>((ref) async {
  await HiveService.init();
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

////Providers Family for CRUD Operations

final chantierProvider = Provider.family<Chantier?, String>((ref, id) {
  final box = Hive.box<Chantier>('chantiers');
  return box.get(id);
});

final allChantiersProvider = Provider<List<Chantier>>((ref) {
  final box = Hive.box<Chantier>('chantiers');
  return box.values.toList();
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

final chantierEtapesProvider =
    FutureProvider.family<List<ChantierEtape>, String>((ref, chantierId) async {
      final box = await ref.watch(chantierEtapeBoxProvider);
      return box.values.where((e) => e.id == chantierId).toList();
    });

final allEtapesProvider = Provider<List<ChantierEtape>>((ref) {
  final box = Hive.box<ChantierEtape>('chantier_etapes');
  return box.values.toList();
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

////Services for CRUD Operations
final chantierServiceProvider = Provider<EntityServices<Chantier>>(
  (ref) => const EntityServices('chantiers'),
);

final clientServiceProvider = Provider<EntityServices<Client>>(
  (ref) => const EntityServices('clients'),
);

final technicienServiceProvider = Provider<EntityServices<Technicien>>(
  (ref) => const EntityServices('techniciens'),
);

final interventionServiceProvider = Provider<EntityServices<Intervention>>(
  (ref) => const EntityServices('interventions'),
);

final chantierEtapeServiceProvider = Provider<EntityServices<ChantierEtape>>(
  (ref) => const EntityServices('chantierEtapes'),
);

final pieceJointeServiceProvider = Provider<EntityServices<PieceJointe>>(
  (ref) => const EntityServices('piecesJointes'),
);

final pieceServiceProvider = Provider<EntityServices<Piece>>(
  (ref) => const EntityServices('pieces'),
);

final materielServiceProvider = Provider<EntityServices<Materiel>>(
  (ref) => const EntityServices('materiels'),
);

final materiauServiceProvider = Provider<EntityServices<Materiau>>(
  (ref) => const EntityServices('materiau'),
);

final mainOeuvreServiceProvider = Provider<EntityServices<MainOeuvre>>(
  (ref) => const EntityServices('mainOeuvre'),
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
  // Ajoutez d'autres services ici
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
