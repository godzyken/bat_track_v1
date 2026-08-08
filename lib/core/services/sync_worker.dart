import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'connectivity_service.dart';
import '../../models/services/entity_sync_services.dart';

/// Worker chargé de relancer les synchronisations quand le réseau revient.
class SyncWorker {
  final Ref ref;
  ProviderSubscription? _subscription;

  SyncWorker(this.ref);

  void start() {
    developer.log('🔄 [SyncWorker] Démarrage du worker de synchronisation');
    
    _subscription = ref.listen<AsyncValue<ConnectivityStatus>>(connectivityStatusProvider, (previous, next) {
      if (next.value == ConnectivityStatus.isConnected) {
        developer.log('📡 [SyncWorker] Réseau détecté, lancement de la synchronisation globale');
        _performFullSync();
      }
    }, fireImmediately: true);
  }

  Future<void> _performFullSync() async {
    try {
      await syncAllEntitiesFromFirestore(ref);
      developer.log('✅ [SyncWorker] Synchronisation globale terminée avec succès');
    } catch (e) {
      developer.log('❌ [SyncWorker] Échec de la synchronisation globale: $e');
    }
  }

  void stop() {
    _subscription?.close();
  }
}

final syncWorkerProvider = Provider<SyncWorker>((ref) {
  final worker = SyncWorker(ref);
  ref.onDispose(() => worker.stop());
  return worker;
});
