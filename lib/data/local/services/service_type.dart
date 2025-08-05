import 'package:firebase_storage/firebase_storage.dart';

import '../../../models/data/json_model.dart';
import '../../../models/services/entity_service.dart';
import '../../remote/services/firebase_service.dart';
import '../../remote/services/storage_service.dart';
import '../models/index_model_extention.dart';
import 'hive_service.dart';

enum StorageMode { hive, firebase, supabase, cloudflare }

mixin StorageHandlerMixin<T extends JsonModel> on Object {
  String get boxName;

  StorageMode get storageMode => StorageMode.hive;

  StorageService get storage => StorageService(FirebaseStorage.instance);

  Future<void> put(String id, T item) async {
    switch (storageMode) {
      case StorageMode.hive:
        await HiveService.put<T>(boxName, id, item);
        break;
      case StorageMode.firebase:
      case StorageMode.cloudflare:
        if (item is HasFile) {
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
      case StorageMode.cloudflare:
        await FirestoreService.deleteData(collectionPath: boxName, docId: id);
        break;
      case StorageMode.supabase:
        throw UnimplementedError('Supabase not yet implemented');
    }
  }

  Future<List<T>> fetchAll({T Function(Map<String, dynamic>)? fromJson}) async {
    switch (storageMode) {
      case StorageMode.hive:
        return HiveService.getAll<T>(boxName);
      case StorageMode.firebase:
      case StorageMode.cloudflare:
        return FirestoreService.getAll<T>(
          collectionPath: boxName,
          fromJson: fromJson!,
        );
      case StorageMode.supabase:
        throw UnimplementedError('Supabase not yet implemented');
    }
  }
}

class EntityServices<T extends JsonModel>
    with StorageHandlerMixin<T>
    implements EntityService<T> {
  @override
  final String boxName;

  @override
  final StorageMode storageMode;

  const EntityServices(this.boxName, {this.storageMode = StorageMode.hive});

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
  T? getById(String id) => HiveService.getSync<T>(boxName, id);

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
    return list ?? [];
  }

  @override
  Future<List<T>> query(String query) async {
    final all = await getAll();
    return all.where((e) => e.toString().contains(query)).toList();
  }

  @override
  Future<void> deleteByQuery(String queryStr) async {
    final list = await query(queryStr);
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
}

final chantierService = EntityServices<Chantier>('chantiers');
final clientService = EntityServices<Client>('clients');
final technicienService = EntityServices<Technicien>('techniciens');
final interventionService = EntityServices<Intervention>('interventions');
final chantierEtapeService = EntityServices<ChantierEtape>('chantierEtapes');
final pieceJointeService = EntityServices<PieceJointe>('piecesJointes');
final pieceService = EntityServices<Piece>('pieces');
final materielService = EntityServices<Materiel>('materiels');
final materiauService = EntityServices<Materiau>('materiau');
final mainOeuvreService = EntityServices<MainOeuvre>('mainOeuvre');
final projetService = EntityServices<Projet>('projets');
final factureService = EntityServices<Facture>('factures');
final factureModelService = EntityServices<FactureModel>('factureModels');
final factureDraftService = EntityServices<FactureDraft>('factureDrafts');
final userService = EntityServices<UserModel>('users');
final equipementService = EntityServices<Equipement>('equipements');

final storageService = StorageService(FirebaseStorage.instance);
