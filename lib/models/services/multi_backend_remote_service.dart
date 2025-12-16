import 'package:async/async.dart';
import 'package:bat_track_v1/data/local/services/service_type.dart';
import 'package:bat_track_v1/models/services/firestore_entity_service.dart';

import '../../data/core/unified_model.dart';
import 'cloud_flare_entity_service.dart';
import 'entity_sync_services.dart';
import 'firebase_entity_service.dart';

class MultiBackendRemoteService<T extends UnifiedModel>
    implements EntityRemoteService<T> {
  final List<StorageMode> enabledBackends;
  final FirestoreEntityService<T>? firestoreService;
  final FirebaseEntityService<T>? firebaseService;
  final CloudflareEntityService<T>? cloudflareService;
  // TODO: Ajouter DolibarrRemoteService<T>? dolibarrService;

  MultiBackendRemoteService({
    required this.enabledBackends,
    this.firestoreService,
    this.firebaseService,
    this.cloudflareService,
  });

  @override
  Future<void> save(T item, String id) async {
    final futures = <Future<void>>[];

    if (enabledBackends.contains(StorageMode.firestore) &&
        firestoreService != null) {
      futures.add(firestoreService!.save(item, id));
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
    final backends = [
      if (enabledBackends.contains(StorageMode.firestore) &&
          firestoreService != null)
        firestoreService!,
      if (enabledBackends.contains(StorageMode.firebase) &&
          firebaseService != null)
        firebaseService!,
      if (enabledBackends.contains(StorageMode.cloudflare) &&
          cloudflareService != null)
        cloudflareService!,
    ];

    for (final backend in backends) {
      final result = await backend.get(id);
      if (result != null) return result;
    }

    return null;
  }

  @override
  Future<List<T>> getAll() async {
    final backends = [
      if (enabledBackends.contains(StorageMode.firestore) &&
          firestoreService != null)
        firestoreService!,
      if (enabledBackends.contains(StorageMode.firebase) &&
          firebaseService != null)
        firebaseService!,
      if (enabledBackends.contains(StorageMode.cloudflare) &&
          cloudflareService != null)
        cloudflareService!,
    ];

    for (final backend in backends) {
      final result = backend.watchAll();
      return result.first;
    }

    return [];
  }

  @override
  Future<void> delete(String id) async {
    final futures = <Future<void>>[];

    if (enabledBackends.contains(StorageMode.firestore) &&
        firestoreService != null) {
      futures.add(firestoreService!.delete(id));
    }
    if (enabledBackends.contains(StorageMode.firebase) &&
        firebaseService != null) {
      futures.add(firebaseService!.delete(id));
    }
    if (enabledBackends.contains(StorageMode.cloudflare) &&
        cloudflareService != null) {
      futures.add(cloudflareService!.delete(id));
    }

    await Future.wait(futures);
  }

  @override
  Stream<List<T>> watchAll() {
    final streams = <Stream<List<T>>>[];

    if (enabledBackends.contains(StorageMode.firestore) &&
        firestoreService != null) {
      streams.add(firestoreService!.watchAll());
    }
    if (enabledBackends.contains(StorageMode.firebase) &&
        firebaseService != null) {
      streams.add(firebaseService!.watchAll());
    }
    if (enabledBackends.contains(StorageMode.cloudflare) &&
        cloudflareService != null) {
      streams.add(cloudflareService!.watchAll());
    }

    if (streams.isEmpty) return Stream.value([]);

    // Merge de tous les streams en un seul
    return StreamGroup.merge(streams);
  }

  @override
  Future fileExists(String path) {
    // TODO: implement fileExists
    throw UnimplementedError();
  }
}
