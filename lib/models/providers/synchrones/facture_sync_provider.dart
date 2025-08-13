import 'package:bat_track_v1/models/providers/asynchrones/remote_service_provider.dart';
import 'package:bat_track_v1/models/services/entity_sync_services.dart';
import 'package:bat_track_v1/providers/hive_firebase_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/models/documents/facture.dart';

final invoiceSyncServiceProvider = Provider<EntitySyncService<Facture>>((ref) {
  final local = ref.read(hiveServiceProvider);
  final remote = ref.read(remoteStorageServiceProvider);
  return EntitySyncService<Facture>(local, remote);
});
