import 'package:bat_track_v1/data/local/services/service_type.dart';
import 'package:bat_track_v1/models/services/firestore_entity_service.dart';
import 'package:bat_track_v1/models/services/supabase_entity_service.dart';

import '../data/json_model.dart';
import 'cloud_flare_entity_service.dart';
import 'entity_sync_services.dart';
import 'firebase_entity_service.dart';

class MultiBackendRemoteService<T extends JsonModel>
    implements EntityRemoteService<T> {
  final List<StorageMode> enabledBackends;
  final FirestoreEntityService<T>? firestoreService;
  final FirebaseEntityService<T>? firebaseService;
  final SupabaseEntityService<T>? supabaseService;
  final CloudflareEntityService<T>? cloudflareService;
  // TODO: Ajouter DolibarrRemoteService<T>? dolibarrService;

  MultiBackendRemoteService({
    required this.enabledBackends,
    this.firestoreService,
    this.firebaseService,
    this.supabaseService,
    this.cloudflareService,
  });

  @override
  Future<void> save(T item, String id) async {
    final futures = <Future<void>>[];

    if (enabledBackends.contains(StorageMode.cloudflare) &&
        firestoreService != null) {
      futures.add(firestoreService!.save(item, id));
    }

    // TODO: Ajouter autres backends
    // if (enabledBackends.contains(BackendType.supabase) && supabaseService != null) {
    //   futures.add(supabaseService!.save(id, item));
    // }
    if (enabledBackends.contains(StorageMode.supabase) &&
        supabaseService != null) {
      futures.add(supabaseService!.save(item, id));
    }

    if (enabledBackends.contains(StorageMode.firebase) &&
        firebaseService != null) {
      futures.add(firebaseService!.save(item, id));
    }

    if (enabledBackends.contains(StorageMode.cloudflare) &&
        cloudflareService != null) {
      futures.add(cloudflareService!.save(item, id));
    }

    await Future.wait(futures);
  }

  @override
  Future<T?> getById(String id) async {
    // Priorité: Firestore > Supabase > Dolibarr
    if (enabledBackends.contains(StorageMode.cloudflare) &&
        firestoreService != null) {
      final result = await firestoreService!.getById(id);
      if (result != null) return result;
    }

    // TODO: Essayer autres backends en fallback

    return null;
  }

  @override
  Future<List<T>> getAll() async {
    // Utilise le premier backend disponible
    if (enabledBackends.contains(StorageMode.cloudflare) &&
        firestoreService != null) {
      return firestoreService!.getAll();
    }

    // TODO: Fallback sur autres backends

    return [];
  }

  @override
  Future<void> delete(String id) async {
    final futures = <Future<void>>[];

    if (enabledBackends.contains(StorageMode.cloudflare) &&
        firestoreService != null) {
      futures.add(firestoreService!.delete(id));
    }

    // TODO: Ajouter autres backends

    await Future.wait(futures);
  }

  @override
  Stream<List<T>> watchAll() {
    // Utilise le premier backend disponible pour le stream
    if (enabledBackends.contains(StorageMode.cloudflare) &&
        firestoreService != null) {
      return firestoreService!.watchAll();
    }

    // TODO: Fallback ou merge de plusieurs streams

    return Stream.value([]);
  }

  @override
  Future fileExists(String path) {
    // TODO: implement fileExists
    throw UnimplementedError();
  }
}
