import 'dart:developer' as developer;

import 'package:bat_track_v1/data/remote/services/supabase_service.dart';
import 'package:bat_track_v1/models/services/firestore_entity_service.dart';
import 'package:bat_track_v1/models/services/multi_backend_remote_service.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../models/data/json_model.dart';
import '../../../models/providers/adapter/hive_remote_storage_wrapper.dart';
import '../../../models/services/cloud_flare_entity_service.dart';
import '../../../models/services/entity_service.dart';
import '../../../models/services/entity_service_registry.dart';
import '../../../models/services/firebase_entity_service.dart';
import '../../../models/services/remote/remote_storage_service.dart';
import '../../../models/services/supabase_entity_service.dart';
import '../../remote/services/firestore_service.dart';
import '../../remote/services/storage_service.dart';
import '../models/index_model_extention.dart';
import 'hive_service.dart';

enum StorageMode { hive, firebase, firestore, supabase, cloudflare }

class AppConfig {
  static StorageMode storageMode = StorageMode.hive;
  static List<StorageMode> enabledBackends = [storageMode];
}

mixin StorageHandlerMixin<T extends JsonModel> on Object {
  String get boxName;

  StorageMode get storageMode => AppConfig.storageMode;

  StorageService get storage => StorageService(FirebaseStorage.instance);

  Future<void> put(String id, T item) async {
    switch (storageMode) {
      case StorageMode.hive:
        await HiveService.put<T>(boxName, id, item);
        break;
      case StorageMode.firebase:
      case StorageMode.firestore:
      case StorageMode.cloudflare:
        if (item is HasFile) {
          developer.log('[ITEM] message :${item.toJson()}');
          final file = (item as HasFile).getFile();
          final path = '$boxName/$id/${file.path.split('/').last}';
          await storage.uploadFile(file, path);
        }
        await FirestoreService.setData<T>(
          collectionPath: boxName,
          docId: id,
          data: item,
        );
        break;
      case StorageMode.supabase:
        throw UnimplementedError('Supabase not yet implemented');
    }
  }

  Future<void> remove(String id) async {
    switch (storageMode) {
      case StorageMode.hive:
        await HiveService.delete<T>(boxName, id);
        break;
      case StorageMode.firebase:
      case StorageMode.firestore:
      case StorageMode.cloudflare:
        await FirestoreService.deleteData(collectionPath: boxName, docId: id);
        break;
      case StorageMode.supabase:
        await SupabaseService.instance.deleteRaw(boxName, id);
        break;
    }
  }

  Future<List<T>> fetchAll({T Function(Map<String, dynamic>)? fromJson}) async {
    switch (storageMode) {
      case StorageMode.hive:
        return HiveService.getAll<T>(boxName);
      case StorageMode.firebase:
      case StorageMode.firestore:
      case StorageMode.cloudflare:
        return FirestoreService.getAll<T>(
          collectionPath: boxName,
          fromJson: fromJson!,
        );
      case StorageMode.supabase:
        return SupabaseService.instance.getAll<T>(boxName, fromJson!);
    }
  }
}

class EntityServices<T extends JsonModel>
    with StorageHandlerMixin<T>
    implements EntityService<T> {
  @override
  final String boxName;
  final RemoteStorageService remoteStorageService;
  final T Function(Map<String, dynamic>) fromJson;

  EntityServices({
    required this.boxName,
    required this.fromJson,
    required this.remoteStorageService,
  });

  @override
  Future<void> save(T item, [String? id]) => put(id ?? item.id, item);

  @override
  Future<void> update(T item, String id) => put(id, item);

  @override
  Future<void> delete(String id) => remove(id);

  @override
  Future<List<T>> getAll() => fetchAll();

  @override
  Future<T?> get(String id) => HiveService.get<T>(boxName, id);

  @override
  Future<T?> getById(String id) => HiveService.getSync<T>(boxName, id);

  @override
  Future<bool> exists(String id) => HiveService.exists<T>(boxName, id);

  @override
  Future<List<String>> getKeys() => HiveService.getKeys<T>(boxName);

  @override
  Future<void> deleteAll() => HiveService.deleteAll<T>();

  @override
  Future<void> clear() => HiveService.clear();

  @override
  Future<void> open() => HiveService.box<T>(boxName);

  @override
  Future<void> init() => HiveService.init();

  @override
  Future<void> closeAll() => HiveService.closeAll();

  @override
  Future<List<T>> where(bool Function(T) test) async {
    final all = await getAll();
    return all.where(test).toList();
  }

  @override
  Future<List<T>> sortedBy(
    Comparable Function(T) selector, {
    bool descending = false,
  }) async {
    final list = await getAll();
    list.sort(
      (a, b) => selector(a).compareTo(selector(b)) * (descending ? -1 : 1),
    );
    return list;
  }

  @override
  Future<List<T>> query(String query) async {
    final all = await getAll();
    return all.where((e) => e.toString().contains(query)).toList();
  }

  @override
  Future<void> deleteByQuery(Map<String, dynamic> queryStr) async {
    if (queryStr.isEmpty) return;
    final fieldName = queryStr.keys.first;

    final list = await query(fieldName);
    for (final item in list) {
      await delete(item.id);
    }
  }

  @override
  Stream<List<T>> watchByChantier(String chantierId) async* {
    final box = await HiveService.box<T>(boxName);
    yield* box.watch().asyncMap((_) async {
      final allItems = await getAll();
      return allItems.where((item) {
        final json = item.toJson();
        return json['chantierId'] == chantierId;
      }).toList();
    });
  }

  Future<List<Map<String, dynamic>>> getAllRaw(
    String collectionOrTable, {
    DateTime? updatedAfter,
    int? limit,
  }) {
    // TODO: implement getAllRaw
    throw UnimplementedError();
  }

  /// Lit la version locale brute
  @override
  Future<Map<String, dynamic>> getLocalRaw(String id) async {
    try {
      final localItem = await HiveService.get<T>(boxName, id);
      return localItem?.toJson() ?? <String, dynamic>{};
    } catch (e, st) {
      developer.log('getLocalRaw error for $boxName/$id: $e\n$st');
      rethrow;
    }
  }

  /// Lit la version distante brute selon le mode de stockage
  @override
  Future<Map<String, dynamic>> getRemoteRaw(String id) async {
    return remoteStorageService.getRaw(boxName, id);
  }

  /// Écrit la version distante brute
  @override
  Future<void> saveRemoteRaw(String id, Map<String, dynamic> data) async {
    await remoteStorageService.saveRaw(boxName, id, data);
  }

  /// Écrit la version locale brute (construit un T depuis JSON via JsonModelFactory)
  @override
  Future<void> saveLocalRaw(String id, Map<String, dynamic> data) async {
    try {
      final instance = JsonModelFactory.fromDynamic<T>(data);
      if (instance == null) {
        throw Exception(
          'No JsonModelFactory registered for $T -> cannot save local raw',
        );
      }
      await HiveService.put<T>(boxName, id, instance);
    } catch (e, st) {
      developer.log('saveLocalRaw error for $boxName/$id: $e\n$st');
      rethrow;
    }
  }

  @override
  Future<List<T>> getByQuery(Map<String, dynamic> query) async {
    final allItems = await getAll();
    return allItems.where((item) {
      final json = item.toJson();
      return query.entries.every((e) => json[e.key] == e.value);
    }).toList();
  }

  @override
  Stream<List<T>> watchAll() async* {
    final box = await HiveService.box<T>(boxName);
    yield* box.watch().asyncMap((_) async {
      return await getAll();
    });
  }

  @override
  Stream<List<T>> watchByQuery(Map<String, dynamic> query) async* {
    final box = await HiveService.box<T>(boxName);
    yield* box.watch().asyncMap((_) async {
      final allItems = await getAll();
      return allItems.where((item) {
        final json = item.toJson();
        return query.entries.every((e) => json[e.key] == e.value);
      }).toList();
    });
  }

  Future<T?> getRawRemote(String id) async {
    final json = await remoteStorageService.getRaw(boxName, id);
    if (json.isEmpty) return null;
    return fromJson(json);
  }

  Future<List<T>> getAllRawRemote({DateTime? updatedAfter, int? limit}) async {
    final list = await remoteStorageService.getAllRaw(
      boxName,
      updatedAfter: updatedAfter,
      limit: limit,
    );
    return list.map(fromJson).toList();
  }

  Future<void> saveRawRemote(T entity) async {
    await remoteStorageService.saveRaw(boxName, entity.id, entity.toJson());
  }

  Future<void> deleteRawRemote(String id) async {
    await remoteStorageService.deleteRaw(boxName, id);
  }

  Stream<List<T>> watchAllRawRemote({Function(dynamic query)? queryBuilder}) {
    return remoteStorageService
        .watchCollectionRaw(boxName, queryBuilder: queryBuilder)
        .map((rows) => rows.map(fromJson).toList());
  }
}

class EntityServiceFactory {
  EntityServiceFactory._(); // private constructor

  static final EntityServiceFactory instance = EntityServiceFactory._();

  /// Crée un service adapté au mode de stockage choisi
  EntityService<T> create<T extends JsonModel>({
    required String boxNameOrCollectionName,
    required T Function(Map<String, dynamic>) fromJson,
    String? supabaseTable,
  }) {
    switch (AppConfig.storageMode) {
      case StorageMode.hive:
      case StorageMode.firestore:
      case StorageMode.firebase:
      case StorageMode.supabase:
      case StorageMode.cloudflare:
        // Définir les backends activés à partir de AppConfig

        final multiBackend = MultiBackendRemoteService<T>(
          enabledBackends: AppConfig.enabledBackends,
          firestoreService: FirestoreEntityService(
            collectionPath: boxNameOrCollectionName,
            fromJson: fromJson,
          ),
          firebaseService: FirebaseEntityService(
            collectionPath: boxNameOrCollectionName,
            fromJson: fromJson,
          ),
          supabaseService: SupabaseEntityService(
            table: supabaseTable ?? boxNameOrCollectionName,
            fromJson: fromJson,
          ),
          cloudflareService: CloudflareEntityService(
            collectionName: boxNameOrCollectionName,
            fromJson: fromJson,
          ),
        );

        return EntityServices<T>(
          boxName: boxNameOrCollectionName,
          fromJson: fromJson,
          remoteStorageService: HiveRemoteStorageWrapper<T>(
            multiBackend: multiBackend,
          ),
        );
    }
  }
}

final chantierService = buildEntityServiceProvider<Chantier>(
  collectionOrBoxName: 'chantiers',
  fromJson: Chantier.fromJson,
);

final clientService = buildEntityServiceProvider<Client>(
  collectionOrBoxName: 'clients',
  fromJson: Client.fromJson,
);
final technicienService = buildEntityServiceProvider<Technicien>(
  collectionOrBoxName: 'techniciens',
  fromJson: Technicien.fromJson,
);
final interventionService = buildEntityServiceProvider<Intervention>(
  collectionOrBoxName: 'interventions',
  fromJson: Intervention.fromJson,
);
final chantierEtapeService = buildEntityServiceProvider<ChantierEtape>(
  collectionOrBoxName: 'chantierEtapes',
  fromJson: ChantierEtape.fromJson,
);
final pieceJointeService = buildEntityServiceProvider<PieceJointe>(
  collectionOrBoxName: 'piecesJointes',
  fromJson: PieceJointe.fromJson,
);
final pieceService = buildEntityServiceProvider<Piece>(
  collectionOrBoxName: 'pieces',
  fromJson: Piece.fromJson,
);
final materielService = buildEntityServiceProvider<Materiel>(
  collectionOrBoxName: 'materiels',
  fromJson: Materiel.fromJson,
);
final materiauService = buildEntityServiceProvider<Materiau>(
  collectionOrBoxName: 'materiau',
  fromJson: Materiau.fromJson,
);
final mainOeuvreService = buildEntityServiceProvider<MainOeuvre>(
  collectionOrBoxName: 'mainOeuvre',
  fromJson: MainOeuvre.fromJson,
);
final projetService = buildEntityServiceProvider<Projet>(
  collectionOrBoxName: 'projets',
  fromJson: Projet.fromJson,
);
final factureService = buildEntityServiceProvider<Facture>(
  collectionOrBoxName: 'factures',
  fromJson: Facture.fromJson,
);
final factureModelService = buildEntityServiceProvider<FactureModel>(
  collectionOrBoxName: 'factureModels',
  fromJson: FactureModel.fromJson,
);
final factureDraftService = buildEntityServiceProvider<FactureDraft>(
  collectionOrBoxName: 'factureDrafts',
  fromJson: FactureDraft.fromJson,
);
final userService = buildEntityServiceProvider<UserModel>(
  collectionOrBoxName: 'users',
  fromJson: UserModel.fromJson,
);
final equipementService = buildEntityServiceProvider<Equipement>(
  collectionOrBoxName: 'equipements',
  fromJson: Equipement.fromJson,
);

final storageService = StorageService(FirebaseStorage.instance);
final firebaseService = FirestoreService();
