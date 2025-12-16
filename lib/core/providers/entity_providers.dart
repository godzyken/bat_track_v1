import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/core/unified_model.dart';
import '../../data/local/models/index_model_extention.dart';
import '../../models/providers/asynchrones/remote_service_provider.dart';
import '../services/unified_entity_service.dart';

// ═══════════════════════════════════════════════════════════════
// PROVIDER GÉNÉRIQUE
// ═══════════════════════════════════════════════════════════════

/// Provider générique pour créer un UnifiedEntityService
Provider<UnifiedEntityService<T>>
entityServiceProvider<T extends UnifiedModel>({
  required String collectionName,
  required T Function(Map<String, dynamic>) fromJson,
}) {
  return Provider<UnifiedEntityService<T>>((ref) {
    return UnifiedEntityService<T>(
      collectionName: collectionName,
      fromJson: fromJson,
      remoteStorage: ref.watch(remoteStorageServiceProvider),
    );
  });
}

// ═══════════════════════════════════════════════════════════════
// PROVIDERS SPÉCIFIQUES (REMPLACE TOUS LES ANCIENS)
// ═══════════════════════════════════════════════════════════════

// Chantier
final chantierServiceProvider = entityServiceProvider<Chantier>(
  collectionName: 'chantiers',
  fromJson: Chantier.fromJson,
);

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
final clientServiceProvider = entityServiceProvider<Client>(
  collectionName: 'clients',
  fromJson: Client.fromJson,
);

final clientListProvider = StreamProvider<List<Client>>((ref) {
  return ref.watch(clientServiceProvider).watchAll();
});

// ChantierEtape
final chantierEtapeServiceProvider = entityServiceProvider<ChantierEtape>(
  collectionName: 'chantierEtapes',
  fromJson: ChantierEtape.fromJson,
);

final chantierEtapeListProvider = StreamProvider<List<ChantierEtape>>((ref) {
  return ref.watch(chantierEtapeServiceProvider).watchAll();
});

// Technicien
final technicienServiceProvider = entityServiceProvider<Technicien>(
  collectionName: 'techniciens',
  fromJson: Technicien.fromJson,
);

final technicienListProvider = StreamProvider<List<Technicien>>((ref) {
  return ref.watch(technicienServiceProvider).watchAll();
});

// Piece
final pieceServiceProvider = entityServiceProvider<Piece>(
  collectionName: 'pieces',
  fromJson: Piece.fromJson,
);

final pieceListProvider = StreamProvider<List<Piece>>((ref) {
  return ref.watch(pieceServiceProvider).watchAll();
});

// PieceJointe
final pieceJointeServiceProvider = entityServiceProvider<PieceJointe>(
  collectionName: 'piecesJointes',
  fromJson: PieceJointe.fromJson,
);

final pieceJointeListProvider = StreamProvider<List<PieceJointe>>((ref) {
  return ref.watch(pieceJointeServiceProvider).watchAll();
});

// FactureDraft
final factureDraftServiceProvider = entityServiceProvider<FactureDraft>(
  collectionName: 'factureDraft',
  fromJson: FactureDraft.fromJson,
);

final factureDraftListProvider = StreamProvider<List<FactureDraft>>((ref) {
  return ref.watch(factureDraftServiceProvider).watchAll();
});

// Projet
final projetServiceProvider = entityServiceProvider<Projet>(
  collectionName: 'projets',
  fromJson: Projet.fromJson,
);

final projetListProvider = StreamProvider<List<Projet>>((ref) {
  return ref.watch(projetServiceProvider).watchAll();
});

// Intervention
final interventionServiceProvider = entityServiceProvider<Intervention>(
  collectionName: 'interventions',
  fromJson: Intervention.fromJson,
);

final interventionListProvider = StreamProvider<List<Intervention>>((ref) {
  return ref.watch(interventionServiceProvider).watchAll();
});

// Facture
final factureServiceProvider = entityServiceProvider<Facture>(
  collectionName: 'factures',
  fromJson: Facture.fromJson,
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
