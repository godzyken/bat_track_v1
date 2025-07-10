import 'package:bat_track_v1/data/remote/services/file_sync_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/models/index_model_extention.dart';
import '../../../../data/local/providers/hive_provider.dart';
import '../../../../data/local/services/service_type.dart';
import '../../../../data/remote/services/entity_sync_services.dart';
import '../../../../models/data/state_wrapper/wrappers.dart';
import '../../../../models/notifiers/sync_entity_notifier.dart';

final chantierInitialProvider = FutureProvider.family<Chantier, String>((
  ref,
  id,
) async {
  final chantierService = ref.watch(chantierServiceProvider);
  final chantier = await chantierService.get(id);

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

final chantierEtapesTempProvider = StateProvider.autoDispose
    .family<List<ChantierEtape>, String>((ref, id) {
      final chantierAsync = ref.watch(chantierInitialProvider(id));

      return chantierAsync.when(
        data: (chantier) {
          if (chantier == null || chantier.etapes.isEmpty) {
            return [ChantierEtape(titre: '', description: '')];
          }
          return List<ChantierEtape>.from(chantier.etapes);
        },
        loading: () => [],
        error: (_, __) => [],
      );
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

/*final factureSyncServiceProvider =
    Provider<EntitySyncService<Facture>>(²
      (ref) => const EntitySyncService<Facture>('factures'),
    );

final projetSyncServiceProvider =
    Provider<EntitySyncService<Projet>>(
      (ref) => const EntitySyncService<Projet>('projets'),
    );*/

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
    //await ref.read(factureSyncServiceProvider).syncFromFirestore();
    //await ref.read(projetSyncServiceProvider).syncFromFirestore();
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
  //await ref.read(factureSyncServiceProvider).syncFromFirestore();
  //await ref.read(projetSyncServiceProvider).syncFromFirestore();
});
