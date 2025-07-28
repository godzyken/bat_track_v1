import 'dart:developer' as developer;

import 'package:firebase_storage/firebase_storage.dart';

import '../../../models/data/json_model.dart';
import '../../../models/services/entity_service.dart';
import '../../remote/services/firebase_service.dart';
import '../../remote/services/storage_service.dart';
import '../models/index_model_extention.dart';
import 'hive_service.dart';

enum StorageMode { hive, firebase, supabase, cloudflare }

class EntityServices<T extends JsonModel> implements EntityService<T> {
  final String boxName;
  final StorageMode storageMode;

  const EntityServices(this.boxName, {this.storageMode = StorageMode.hive});

  Future<void> add(T item, String id) async {
    if (storageMode == StorageMode.hive) {
      await HiveService.put<T>(boxName, id, item);
    } else if (storageMode == StorageMode.firebase ||
        storageMode == StorageMode.cloudflare) {
      if (item is HasFile) {
        final storage = StorageService(FirebaseStorage.instance);
        final path =
            '$boxName/$id/${(item as HasFile).getFile().path.split('/').last}';
        await storage.uploadFile((item as HasFile).getFile(), path);
      }

      await FirestoreService.setData<T>(
        collectionPath: boxName,
        docId: id,
        data: item,
      );
    } else {
      throw Exception('Invalid storage mode');
    }
  }

  @override
  Future<void> update(T item, String id) =>
      HiveService.put<T>(boxName, id, item);

  @override
  Future<void> delete(String id) => HiveService.delete<T>(boxName, id);

  @override
  Future<void> deleteByQuery(String queryStr) async {
    final list = await query(queryStr);
    for (final item in list) {
      await delete(item.copyWithId(queryStr));
    }
  }

  @override
  Future<void> deleteAll() => HiveService.deleteAll<T>();

  @override
  Future<List<T>> getAll() async {
    final sw = Stopwatch()..start();
    developer.log('⏳ Sync cloud => $boxName');

    final modelsFromHive = await HiveService.getAll<T>(boxName);

    sw.stop();
    developer.log(
      '✅ $boxName sync terminé en ${sw.elapsedMilliseconds}ms (n=${modelsFromHive.length})',
    );

    return modelsFromHive;
  }

  @override
  T? getById(String id) {
    // Attention : méthode synchrone basée sur cache local
    return HiveService.getSync<T>(boxName, id);
  }

  @override
  Future<T?> get(String id) => HiveService.get<T>(boxName, id);

  @override
  Future<bool> exists(String id) => HiveService.exists<T>(boxName, id);

  @override
  Future<List<String>> getKeys() => HiveService.getKeys<T>(boxName);

  @override
  Future<void> save(T item, String id) async {
    if (await exists(id)) {
      await update(item, id);
    } else {
      await add(item, id);
    }
  }

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
    return all.where((element) => element.toString().contains(query)).toList();
  }

  @override
  Future<void> closeAll() => HiveService.closeAll();

  @override
  Future<void> open() => HiveService.box<T>(boxName);

  @override
  Future<void> init() => HiveService.init();

  @override
  Future<void> clear() => HiveService.clear();
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
