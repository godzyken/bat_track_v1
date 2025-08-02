import 'package:bat_track_v1/data/remote/services/entity_sync_services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/models/documents/facture.dart';

final invoiceSyncServiceProvider = Provider<EntitySyncService<Facture>>((ref) {
  return EntitySyncService<Facture>('factures');
});
