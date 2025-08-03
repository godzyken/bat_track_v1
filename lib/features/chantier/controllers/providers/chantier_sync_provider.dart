import 'package:bat_track_v1/models/services/file_sync_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/models/index_model_extention.dart';
import '../../../../data/local/providers/hive_provider.dart';
import '../../../../data/local/services/service_type.dart';
import '../../../../models/data/state_wrapper/wrappers.dart';
import '../../../../models/notifiers/sync_entity_notifier.dart';
import '../../../../models/services/entity_sync_services.dart';

final chantierInitialProvider = FutureProvider.family<Chantier, String>((
  ref,
  id,
) async {
  final chantierService = ref.watch(chantierServiceProvider);
  final chantier = chantierService.getById(id);

  return chantier ??
      Chantier(
        id: id,
        nom: '',
        adresse: '',
        clientId: '',
        dateDebut: DateTime.now(),
      );
});

final chantierSyncProvider = StateNotifierProvider.autoDispose
    .family<SyncEntityNotifier<Chantier>, SyncedState<Chantier>, Chantier>((
      ref,
      chantier,
    ) {
      return SyncEntityNotifier<Chantier>(
        entityService: chantierService,
        storageService: storageService,
        initialState: chantier,
      );
    });

final chantierEtapesTempProvider = FutureProvider.autoDispose
    .family<List<ChantierEtape>, String>((ref, id) async {
      final chantier = await ref.watch(chantierInitialProvider(id).future);

      if (chantier.etapes.isEmpty) {
        return [ChantierEtape.mock()];
      }
      return List<ChantierEtape>.from(chantier.etapes);
    });

final chantierSyncServiceProvider = Provider<EntitySyncService<Chantier>>(
  (ref) => EntitySyncService<Chantier>('chantiers'),
);

final pieceJointeSyncServiceProvider = Provider<FileSyncService<PieceJointe>>(
  (ref) => FileSyncService<PieceJointe>('piecesJointes'),
);

final pieceSyncServiceProvider = Provider<EntitySyncService<Piece>>(
  (ref) => EntitySyncService<Piece>('pieces'),
);

final materielSyncServiceProvider = Provider<EntitySyncService<Materiel>>(
  (ref) => EntitySyncService<Materiel>('materiels'),
);

final materiauSyncServiceProvider = Provider<EntitySyncService<Materiau>>(
  (ref) => EntitySyncService<Materiau>('materiau'),
);

final mainOeuvreSyncServiceProvider = Provider<EntitySyncService<MainOeuvre>>(
  (ref) => EntitySyncService<MainOeuvre>('mainOeuvre'),
);

final techSyncServiceProvider = Provider<EntitySyncService<Technicien>>(
  (ref) => EntitySyncService<Technicien>('techniciens'),
);

final clientSyncServiceProvider = Provider<EntitySyncService<Client>>(
  (ref) => EntitySyncService<Client>('clients'),
);

final interventionSyncServiceProvider =
    Provider<EntitySyncService<Intervention>>(
      (ref) => EntitySyncService<Intervention>('interventions'),
    );

final chantierEtapeSyncServiceProvider =
    Provider<EntitySyncService<ChantierEtape>>(
      (ref) => EntitySyncService<ChantierEtape>('chantierEtapes'),
    );

final factureSyncServiceProvider = Provider<EntitySyncService<Facture>>(
  (ref) => EntitySyncService<Facture>('factures'),
);

final projetSyncServiceProvider = Provider<EntitySyncService<Projet>>(
  (ref) => EntitySyncService<Projet>('projets'),
);

final userSyncServiceProvider = Provider<EntitySyncService<UserModel>>(
  (ref) => EntitySyncService<UserModel>('users'),
);

final syncAllProvider = Provider(
  (ref) => () async {
    await ref.read(chantierSyncServiceProvider).syncFromFirestore();
    await ref.read(pieceJointeSyncServiceProvider).syncFromFirestore();
    await ref.read(materielSyncServiceProvider).syncFromFirestore();
    await ref.read(materiauSyncServiceProvider).syncFromFirestore();
    await ref.read(mainOeuvreSyncServiceProvider).syncFromFirestore();
    await ref.read(techSyncServiceProvider).syncFromFirestore();
    await ref.read(clientSyncServiceProvider).syncFromFirestore();
    await ref.read(interventionSyncServiceProvider).syncFromFirestore();
    await ref.read(pieceSyncServiceProvider).syncFromFirestore();
    await ref.read(chantierEtapeSyncServiceProvider).syncFromFirestore();
    await ref.read(factureSyncServiceProvider).syncFromFirestore();
    await ref.read(projetSyncServiceProvider).syncFromFirestore();
    await ref.read(userSyncServiceProvider).syncFromFirestore();
  },
);

final syncAllEntitiesProvider = FutureProvider<void>((ref) async {
  await ref.read(chantierSyncServiceProvider).syncFromFirestore();
  await ref.read(pieceJointeSyncServiceProvider).syncFromFirestore();
  await ref.read(materielSyncServiceProvider).syncFromFirestore();
  await ref.read(materiauSyncServiceProvider).syncFromFirestore();
  await ref.read(mainOeuvreSyncServiceProvider).syncFromFirestore();
  await ref.read(techSyncServiceProvider).syncFromFirestore();
  await ref.read(clientSyncServiceProvider).syncFromFirestore();
  await ref.read(interventionSyncServiceProvider).syncFromFirestore();
  await ref.read(pieceSyncServiceProvider).syncFromFirestore();
  await ref.read(chantierEtapeSyncServiceProvider).syncFromFirestore();
  await ref.read(factureSyncServiceProvider).syncFromFirestore();
  await ref.read(projetSyncServiceProvider).syncFromFirestore();
  await ref.read(userSyncServiceProvider).syncFromFirestore();
});

final allDataStreamProvider = StreamProvider.autoDispose((ref) async* {
  final clients =
      await ref
          .read(clientSyncServiceProvider)
          .firestore
          .collection('clients')
          .get();
  final techniciens =
      await ref
          .read(techSyncServiceProvider)
          .firestore
          .collection('techniciens')
          .get();
  final chantiers =
      await ref
          .read(chantierSyncServiceProvider)
          .firestore
          .collection('chantiers')
          .get();

  yield {
    'clients': clients.docs,
    'techniciens': techniciens.docs,
    'chantiers': chantiers.docs,
  };
});
