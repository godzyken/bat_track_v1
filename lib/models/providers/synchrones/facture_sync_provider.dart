import 'package:bat_track_v1/models/services/entity_sync_services.dart';

import 'package:shared_models/shared_models.dart';

final factureSyncServiceProvider = entitySyncServiceProvider<Facture>(
  'factures',
  Facture.fromJson,
);
