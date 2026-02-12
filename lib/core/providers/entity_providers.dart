import 'package:bat_track_v1/data/local/models/entities/index_entity_extention.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_models/shared_models.dart';

import '../../data/local/models/adapters/hive_entity_factory.dart';
import '../../data/local/models/index_model_extention.dart';
import '../../data/remote/providers/chantier_provider.dart';
import '../../data/remote/providers/multi_backend_remote_provider.dart';
import '../../models/data/hive_model.dart';
import '../services/unified_entity_service.dart';
import '../services/unified_entity_service_impl.dart';

// ═══════════════════════════════════════════════════════════════
// PROVIDER GÉNÉRIQUE
// ═══════════════════════════════════════════════════════════════

/// Provider générique pour créer un UnifiedEntityService
Provider<UnifiedEntityService<M, E>> unifiedEntityServiceProvider<
  M extends UnifiedModel,
  E extends HiveModel<M>
>({required String collectionName, required HiveEntityFactory<M, E> factory}) {
  return Provider<UnifiedEntityService<M, E>>((ref) {
    final remote = ref.watch(multiBackendRemoteProvider);

    return ConcreteUnifiedService<M, E>(
      collectionName: collectionName,
      factory: factory,
      remoteStorage: remote,
    );
  });
}

class ConcreteUnifiedService<M extends UnifiedModel, E extends HiveModel<M>>
    extends UnifiedEntityService<M, E> {
  ConcreteUnifiedService({
    required super.collectionName,
    required super.factory,
    required super.remoteStorage,
  });

  @override
  Future<List<M>> getAll() {
    // TODO: implement getAll
    throw UnimplementedError();
  }
}

// ═══════════════════════════════════════════════════════════════
// PROVIDERS SPÉCIFIQUES (REMPLACE TOUS LES ANCIENS)
// ═══════════════════════════════════════════════════════════════

final chantierListProvider = StreamProvider<List<Chantier>>((ref) {
  return ref.watch(chantierServiceProvider).watchAll();
});

// 1. StreamProvider.family qui écoute une seule entité
final watchChantierProvider = StreamProvider.family<Chantier?, String>((
  ref,
  id,
) {
  // Lit l'instance du service unifié (injection de dépendances)
  final service = ref.watch(chantierServiceProvider);

  // Le StreamProvider retourne le Stream<Chantier?> du service.
  // Riverpod gère la souscription et l'annulation automatique.
  return service.watch(id);
});

// Client
final clientServiceProvider =
    unifiedEntityServiceProvider<Client, ClientEntity>(
      collectionName: 'clients',
      factory: ClientEntityFactory(),
    );

final clientListProvider = StreamProvider<List<Client>>((ref) {
  return ref.watch(clientServiceProvider).watchAll();
});

// ChantierEtape
final chantierEtapeServiceProvider =
    unifiedEntityServiceProvider<ChantierEtape, ChantierEtapesEntity>(
      collectionName: 'chantierEtapes',
      factory: ChantierEtapeEntityFactory(),
    );

final chantierEtapeListProvider = StreamProvider<List<ChantierEtape>>((ref) {
  return ref.watch(chantierEtapeServiceProvider).watchAll();
});

// Technicien
final technicienServiceProvider =
    syncedEntityProvider<Technicien, TechnicienEntity>(
      collectionName: 'techniciens',
      factory: TechnicienEntityFactory(),
    );

final technicienListProvider = StreamProvider<List<Technicien>>((ref) {
  return ref.watch(technicienServiceProvider).watchAll();
});

// Piece
final pieceServiceProvider = syncedEntityProvider<Piece, PieceEntity>(
  collectionName: 'pieces',
  factory: PieceEntityFactory(),
);

final pieceListProvider = StreamProvider<List<Piece>>((ref) {
  return ref.watch(pieceServiceProvider).watchAll();
});

// PieceJointe
final pieceJointeServiceProvider =
    syncedEntityProvider<PieceJointe, PieceJointeEntity>(
      collectionName: 'piecesJointes',
      factory: PieceJointeEntityFactory(),
    );

final pieceJointeListProvider = StreamProvider<List<PieceJointe>>((ref) {
  return ref.watch(pieceJointeServiceProvider).watchAll();
});

// FactureDraft
final factureDraftServiceProvider =
    syncedEntityProvider<FactureDraft, FactureDraftEntity>(
      collectionName: 'factureDraft',
      factory: FactureDraftEntityFactory(),
    );

final factureDraftListProvider = StreamProvider<List<FactureDraft>>((ref) {
  return ref.watch(factureDraftServiceProvider).watchAll();
});

// Projet
final projetServiceProvider = syncedEntityProvider<Projet, ProjetEntity>(
  collectionName: 'projets',
  factory: ProjetEntityFactory(),
);

final projetListProvider = StreamProvider<List<Projet>>((ref) {
  return ref.watch(projetServiceProvider).watchAll();
});

// Intervention
final interventionServiceProvider =
    syncedEntityProvider<Intervention, InterventionEntity>(
      collectionName: 'interventions',
      factory: InterventionEntityFactory(),
    );

final interventionListProvider = StreamProvider<List<Intervention>>((ref) {
  return ref.watch(interventionServiceProvider).watchAll();
});

// Facture
final factureServiceProvider = syncedEntityProvider<Facture, FactureEntity>(
  collectionName: 'factures',
  factory: FactureEntityFactory(),
);

final factureListProvider = StreamProvider<List<Facture>>((ref) {
  return ref.watch(factureServiceProvider).watchAll();
});

// ═══════════════════════════════════════════════════════════════
// PROVIDER DE SYNCHRONISATION GLOBALE
// ═══════════════════════════════════════════════════════════════

final syncAllProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    await ref.read(chantierServiceProvider).syncAllFromRemote();
    await ref.read(clientServiceProvider).syncAllFromRemote();
    await ref.read(technicienServiceProvider).syncAllFromRemote();
    await ref.read(projetServiceProvider).syncAllFromRemote();
    await ref.read(interventionServiceProvider).syncAllFromRemote();
    await ref.read(factureServiceProvider).syncAllFromRemote();
  };
});
