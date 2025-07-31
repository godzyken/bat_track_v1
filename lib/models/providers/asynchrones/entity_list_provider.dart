import 'package:bat_track_v1/features/documents/controllers/notifiers/document_list_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/models/index_model_extention.dart';
import '../../../features/chantier/controllers/notifiers/chantier_etapes_list_notifier.dart';
import '../../../features/chantier/controllers/notifiers/chantiers_list_notifier.dart';
import '../../../features/client/controllers/notifiers/clients_list_notifier.dart';
import '../../../features/equipement/controllers/notifiers/equipements_list_notifier.dart';
import '../../../features/technicien/controllers/notifiers/technicien_list_notifier.dart';

final entityListProvider = Provider.family<
  AsyncNotifierProvider<AsyncNotifier<List<dynamic>>, List<dynamic>>,
  Type
>((ref, type) {
  if (type == Chantier) return chantierListProvider;
  if (type == ChantierEtape) return chantierEtapesListProvider;
  if (type == Client) return clientListProvider;
  if (type == Equipement) return equipementListProvider;
  if (type == Facture) return documentListProvider;
  if (type == FactureDraft) return documentListProvider;
  if (type == PieceJointe) return documentListProvider;
  //if (type == Piece) return pieceListProvider;
  if (type == Technicien) return techniciensListProvider;
  throw UnimplementedError('Pas de provider pour $type');
});
