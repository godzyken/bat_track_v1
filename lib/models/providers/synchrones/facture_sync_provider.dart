import 'package:bat_track_v1/models/services/entity_sync_services.dart';

import '../../../data/local/models/documents/facture.dart';

final invoiceSyncServiceProvider = entitySyncServiceProvider<Facture>(
  'factures',
  Facture.fromJson,
);
