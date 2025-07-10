import 'package:firebase_storage/firebase_storage.dart';

import '../../../models/data/json_model.dart';
import '../../remote/services/firebase_service.dart';
import '../../remote/services/storage_service.dart';
import '../models/index_model_extention.dart';
import 'hive_service.dart';

enum StorageMode { hive, firebase, supabase, cloudflare }

class EntityService<T> {
  final String boxName;
  final StorageMode storageMode;

  const EntityService(this.boxName, {this.storageMode = StorageMode.hive});

  Future<void> add(T item, String id) async {
    if (storageMode == StorageMode.hive) {
      await HiveService.put<T>(boxName, id, item);
    } else if (storageMode == StorageMode.firebase) {
      if (item is HasFile) {
        final storage = StorageService(FirebaseStorage.instance);
        final path = '$boxName/$id/${item.getFile().path.split('/').last}';
        await storage.uploadFile(item.getFile(), path);
      }
      await FirestoreService.setData<T>(
        collectionPath: boxName,
        docId: id,
        data: (item as JsonModel).toJson(),
      );
    } else if (storageMode == StorageMode.cloudflare) {
      await FirestoreService.setData<T>(
        collectionPath: boxName,
        docId: id,
        data: (item as JsonModel).toJson(),
      );
    } else {
      throw Exception('Invalid storage mode');
    }
  }

  Future<void> update(T item, String id) =>
      HiveService.put<T>(boxName, id, item);

  Future<void> delete(String id) => HiveService.delete<T>(boxName, id);

  Future<List<T>> getAll() => HiveService.getAll<T>(boxName);

  Future<T?> get(String id) => HiveService.get<T>(boxName, id);

  Future<bool> exists(String id) => HiveService.exists<T>(boxName, id);

  Future<List<String>> getKeys() => HiveService.getKeys<T>(boxName);

  Future<void> save(T item, String id) async {
    if (await exists(id)) {
      await update(item, id);
    } else {
      await add(item, id);
    }
  }

  Future<List<T>> where(bool Function(T) test) async {
    final all = await getAll();
    return all.where(test).toList();
  }

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
}

final chantierService = EntityService<Chantier>('chantiers');
final clientService = EntityService<Client>('clients');
final technicienService = EntityService<Technicien>('techniciens');
final interventionService = EntityService<Intervention>('interventions');
final chantierEtapeService = EntityService<ChantierEtape>('chantierEtapes');
final pieceJointeService = EntityService<PieceJointe>('piecesJointes');
final pieceService = EntityService<Piece>('pieces');
final materielService = EntityService<Materiel>('materiels');
final materiauService = EntityService<Materiau>('materiau');
final mainOeuvreService = EntityService<MainOeuvre>('mainOeuvre');

final storageService = StorageService(FirebaseStorage.instance);
//final factureService = EntityService<Facture>('factures');
//final projetService = EntityService<Projet>('projets');
