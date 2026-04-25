import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_ce/hive.dart';
import 'package:http/http.dart' as http;
import 'package:shared_models/shared_models.dart';

import '../../../data/remote/providers/dolibarr_instance_provider.dart';
import '../../models/data/adapter/safe_async_mixin.dart';
import '../../models/data/adapter/typedefs.dart';
import '../../models/data/maperror/logged_action.dart';

/// Configuration du repository
class RepositoryConfig<T extends UnifiedModel> {
  final String collectionPath;
  final String dolibarrEndpoint;
  final T Function(Map<String, dynamic>) fromJson;
  final bool enableHive;
  final bool enableFirebase;
  final bool enableDolibarr;

  const RepositoryConfig({
    required this.collectionPath,
    required this.dolibarrEndpoint,
    required this.fromJson,
    this.enableHive = true,
    this.enableFirebase = true,
    this.enableDolibarr = false,
  });
}

/// Repository unifié gérant Hive + Firebase + Dolibarr
class UnifiedRepository<T extends UnifiedModel>
    with LoggedAction, SafeAsyncMixin<T> {
  final RepositoryConfig<T> config;
  final Reader ref;

  Box<Map>? _hiveBox;
  CollectionReference<Map<String, dynamic>>? _firebaseCollection;

  UnifiedRepository(this.config, this.ref) {
    initLogger(ref);
    initSafeAsync(ref);
  }

  // ==================== HIVE ====================

  Future<Box<Map>> _getHiveBox() async {
    _hiveBox ??= await Hive.openBox<Map>(config.collectionPath);
    return _hiveBox!;
  }

  Future<void> saveToHive(T model) async {
    if (!config.enableHive) return;

    return safeVoid(
      () async {
        final box = await _getHiveBox();
        await box.put(model.id, model.toJson());
        logAction(
          action: 'save_to_hive',
          target: '${T.toString()}:${model.id}',
        );
      },
      context: 'saveToHive',
      logError: true,
    );
  }

  Future<T?> getFromHive(String id) async {
    if (!config.enableHive) return null;

    return safeAsync(
      () async {
        final box = await _getHiveBox();
        final json = box.get(id) as Map<String, dynamic>?;
        return json != null ? config.fromJson(json) : null;
      },
      context: 'getFromHive',
      fallback: null,
    );
  }

  Future<List<T>> getAllFromHive() async {
    if (!config.enableHive) return [];

    return safeAsync(
      () async {
        final box = await _getHiveBox();
        return box.values
            .map((e) => config.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      },
      context: 'getAllFromHive',
      fallback: [],
    );
  }

  Future<void> deleteFromHive(String id) async {
    if (!config.enableHive) return;

    return safeVoid(() async {
      final box = await _getHiveBox();
      await box.delete(id);
      logAction(action: 'delete_from_hive', target: '${T.toString()}:$id');
    }, context: 'deleteFromHive');
  }

  // ==================== FIREBASE ====================

  CollectionReference<Map<String, dynamic>> _getFirebaseCollection() {
    _firebaseCollection ??= FirebaseFirestore.instance.collection(
      config.collectionPath,
    );
    return _firebaseCollection!;
  }

  Future<void> saveToFirebase(T model) async {
    if (!config.enableFirebase) return;

    return safeVoid(
      () async {
        await _getFirebaseCollection()
            .doc(model.id)
            .set(model.toJson(), SetOptions(merge: true));
        logAction(
          action: 'save_to_firebase',
          target: '${T.toString()}:${model.id}',
        );
      },
      context: 'saveToFirebase',
      logError: true,
    );
  }

  Future<T?> getFromFirebase(String id) async {
    if (!config.enableFirebase) return null;

    return safeAsync(
      () async {
        final doc = await _getFirebaseCollection().doc(id).get();
        if (!doc.exists) return null;
        return config.fromJson({...doc.data()!, 'id': doc.id});
      },
      context: 'getFromFirebase',
      fallback: null,
    );
  }

  Future<List<T>> getAllFromFirebase({int limit = 100}) async {
    if (!config.enableFirebase) return [];

    return safeAsync(
      () async {
        final snapshot = await _getFirebaseCollection().limit(limit).get();
        return snapshot.docs
            .map((doc) => config.fromJson({...doc.data(), 'id': doc.id}))
            .toList();
      },
      context: 'getAllFromFirebase',
      fallback: [],
    );
  }

  Stream<List<T>> watchFirebase() {
    if (!config.enableFirebase) return Stream.value([]);

    return _getFirebaseCollection().snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => config.fromJson({...doc.data(), 'id': doc.id}))
          .toList(),
    );
  }

  Future<void> deleteFromFirebase(String id) async {
    if (!config.enableFirebase) return;

    return safeVoid(() async {
      await _getFirebaseCollection().doc(id).delete();
      logAction(action: 'delete_from_firebase', target: '${T.toString()}:$id');
    }, context: 'deleteFromFirebase');
  }

  // ==================== DOLIBARR ====================

  Future<List<T>> fetchFromDolibarr() async {
    if (!config.enableDolibarr) return [];

    return safeAsync(
      () async {
        final instance = ref(selectedInstanceProvider);
        if (instance == null) {
          throw Exception('Aucune instance Dolibarr sélectionnée');
        }

        final url = '${instance.baseUrl}/${config.dolibarrEndpoint}';
        final headers = {'DOLAPIKEY': instance.apiKey};

        final res = await http.get(Uri.parse(url), headers: headers);

        if (res.statusCode == 200) {
          final data = jsonDecode(res.body) as List;
          return data
              .map((json) => config.fromJson(json as Map<String, dynamic>))
              .toList();
        } else {
          throw Exception('Erreur Dolibarr (${res.statusCode}): ${res.body}');
        }
      },
      context: 'fetchFromDolibarr',
      fallback: [],
      logError: true,
    );
  }

  Future<void> pushToDolibarr(T model) async {
    if (!config.enableDolibarr) return;

    return safeVoid(
      () async {
        final instance = ref(selectedInstanceProvider);
        if (instance == null) {
          throw Exception('Aucune instance Dolibarr sélectionnée');
        }

        final url = '${instance.baseUrl}/${config.dolibarrEndpoint}';
        final headers = {
          'DOLAPIKEY': instance.apiKey,
          'Content-Type': 'application/json',
        };

        final res = await http.post(
          Uri.parse(url),
          headers: headers,
          body: jsonEncode(model.toJson()),
        );

        if (res.statusCode != 200 && res.statusCode != 201) {
          throw Exception(
            'Erreur push Dolibarr: ${res.statusCode} ${res.body}',
          );
        }

        logAction(
          action: 'push_to_dolibarr',
          target: '${T.toString()}:${model.id}',
        );
      },
      context: 'pushToDolibarr',
      logError: true,
    );
  }

  // ==================== OPÉRATIONS UNIFIÉES ====================

  /// Sauvegarde dans tous les backends activés
  Future<void> save(T model) async {
    await Future.wait([saveToHive(model), saveToFirebase(model)]);
  }

  /// Récupère depuis le cache local puis Firebase si nécessaire
  Future<T?> get(String id) async {
    // Tentative cache local
    final local = await getFromHive(id);
    if (local != null) return local;

    // Fallback Firebase
    final remote = await getFromFirebase(id);
    if (remote != null) {
      await saveToHive(remote); // Mise en cache
    }
    return remote;
  }

  /// Récupère tous les éléments (cache local prioritaire)
  Future<List<T>> getAll() async {
    final local = await getAllFromHive();
    if (local.isNotEmpty) return local;

    final remote = await getAllFromFirebase();
    for (final item in remote) {
      await saveToHive(item);
    }
    return remote;
  }

  /// Supprime de tous les backends
  Future<void> delete(String id) async {
    await Future.wait([deleteFromHive(id), deleteFromFirebase(id)]);
  }

  /// Synchronisation complète Dolibarr → Hive + Firebase
  Future<int> syncFromDolibarr() async {
    return safeAsync(
      () async {
        final items = await fetchFromDolibarr();
        for (final item in items) {
          await save(item);
        }
        logEvent(
          name: 'dolibarr_sync_complete',
          data: {'count': items.length, 'type': T.toString()},
        );
        return items.length;
      },
      context: 'syncFromDolibarr',
      fallback: 0,
      logError: true,
    );
  }

  /// Nettoyage du cache local
  Future<void> clearCache() async {
    if (!config.enableHive) return;
    final box = await _getHiveBox();
    await box.clear();
  }
}
