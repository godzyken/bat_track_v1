import 'package:bat_track_v1/features/chantier/controllers/notifiers/chantiers_list_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/models/index_model_extention.dart';
import '../../../../data/remote/providers/chantier_provider.dart';
import '../../../../models/providers/synchrones/facture_sync_provider.dart';
import '../../../../models/services/entity_sync_services.dart';
import '../../../auth/data/providers/current_user_provider.dart';

final chantierInitialProvider = FutureProvider.family<Chantier, String>((
  ref,
  id,
) async {
  final chantierService = ref.watch(chantierServiceProvider);
  final chantier = await chantierService.get(id);

  return chantier?.id == id
      ? Chantier(
          id: chantier!.id,
          nom: chantier.nom,
          adresse: chantier.adresse,
          clientId: chantier.clientId,
          dateDebut: chantier.dateDebut,
        )
      : Chantier.mock();
});

final chantierEtapesTempProvider = FutureProvider.autoDispose
    .family<List<ChantierEtape>, String>((ref, id) async {
      final chantier = await ref.watch(chantierInitialProvider(id).future);

      if (chantier.etapes.isEmpty) {
        return [ChantierEtape.mock()];
      }
      return List<ChantierEtape>.from(chantier.etapes);
    });

final chantierSyncServiceProvider = entitySyncServiceProvider<Chantier>(
  'chantiers',
  Chantier.fromJson,
);

final pieceJointeSyncServiceProvider = entitySyncServiceProvider<PieceJointe>(
  'piecesJointes',
  PieceJointe.fromJson,
);

final pieceSyncServiceProvider = entitySyncServiceProvider<Piece>(
  'pieces',
  Piece.fromJson,
);

final materielSyncServiceProvider = entitySyncServiceProvider<Materiel>(
  'materiels',
  Materiel.fromJson,
);

final materiauSyncServiceProvider = entitySyncServiceProvider<Materiau>(
  'materiau',
  Materiau.fromJson,
);

final mainOeuvreSyncServiceProvider = entitySyncServiceProvider<MainOeuvre>(
  'mainOeuvre',
  MainOeuvre.fromJson,
);

final techSyncServiceProvider = entitySyncServiceProvider<Technicien>(
  'techniciens',
  Technicien.fromJson,
);

final clientSyncServiceProvider = entitySyncServiceProvider<Client>(
  'clients',
  Client.fromJson,
);

final interventionSyncServiceProvider = entitySyncServiceProvider<Intervention>(
  'interventions',
  Intervention.fromJson,
);

final chantierEtapeSyncServiceProvider =
    entitySyncServiceProvider<ChantierEtape>(
      'chantierEtapes',
      ChantierEtape.fromJson,
    );

final projetSyncServiceProvider = entitySyncServiceProvider<Projet>(
  'projets',
  Projet.fromJson,
);

final userSyncServiceProvider = entitySyncServiceProvider<UserModel>(
  'users',
  UserModel.fromJson,
);

final filteredChantiersProvider = Provider<AsyncValue<List<Chantier>>>((ref) {
  final chantierAsync = ref.watch(chantierListProvider);
  final userAsync = ref.watch(currentUserProvider);

  if (userAsync.isLoading) return const AsyncValue.loading();
  if (userAsync.hasError) {
    return AsyncValue.error(userAsync.error!, StackTrace.current);
  }

  final user = userAsync.value;

  if (user == null) {
    return const AsyncValue.data([]);
  }

  final isAdmin = user.role == 'admin';
  final isClient = user.role == 'client';
  final isTechnicien = user.role == 'technicien';

  return chantierAsync.whenData((list) {
    if (isAdmin) return list;
    if (isClient) {
      return list.where((c) => c.clientId == user.uid).toList();
    }
    if (isTechnicien) {
      return list.where((c) => c.technicienIds.contains(user.uid)).toList();
    }
    return [];
  });
});

final syncAllProvider = Provider(
  (ref) => () async {
    await ref.read(chantierSyncServiceProvider).syncFromRemote();
    await ref.read(pieceJointeSyncServiceProvider).syncFromRemote();
    await ref.read(materielSyncServiceProvider).syncFromRemote();
    await ref.read(materiauSyncServiceProvider).syncFromRemote();
    await ref.read(mainOeuvreSyncServiceProvider).syncFromRemote();
    await ref.read(techSyncServiceProvider).syncFromRemote();
    await ref.read(clientSyncServiceProvider).syncFromRemote();
    await ref.read(interventionSyncServiceProvider).syncFromRemote();
    await ref.read(pieceSyncServiceProvider).syncFromRemote();
    await ref.read(chantierEtapeSyncServiceProvider).syncFromRemote();
    await ref.read(factureSyncServiceProvider).syncFromRemote();
    await ref.read(projetSyncServiceProvider).syncFromRemote();
    await ref.read(userSyncServiceProvider).syncFromRemote();
  },
);

final syncAllEntitiesProvider = FutureProvider<void>((ref) async {
  await ref.read(chantierSyncServiceProvider).syncFromRemote();
  await ref.read(pieceJointeSyncServiceProvider).syncFromRemote();
  await ref.read(materielSyncServiceProvider).syncFromRemote();
  await ref.read(materiauSyncServiceProvider).syncFromRemote();
  await ref.read(mainOeuvreSyncServiceProvider).syncFromRemote();
  await ref.read(techSyncServiceProvider).syncFromRemote();
  await ref.read(clientSyncServiceProvider).syncFromRemote();
  await ref.read(interventionSyncServiceProvider).syncFromRemote();
  await ref.read(pieceSyncServiceProvider).syncFromRemote();
  await ref.read(chantierEtapeSyncServiceProvider).syncFromRemote();
  await ref.read(factureSyncServiceProvider).syncFromRemote();
  await ref.read(projetSyncServiceProvider).syncFromRemote();
  await ref.read(userSyncServiceProvider).syncFromRemote();
});

final allDataStreamProvider = StreamProvider.autoDispose((ref) async* {
  final clients = ref.read(clientSyncServiceProvider).watchAllCombined();
  final techniciens = ref.read(techSyncServiceProvider).watchAllCombined();
  final chantiers = ref.read(chantierSyncServiceProvider).watchAllCombined();

  yield {
    'clients': clients,
    'techniciens': techniciens,
    'chantiers': chantiers,
  };
});
