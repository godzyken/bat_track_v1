import '../models/index_model_extention.dart';
import 'hive_service.dart';

class EntityService<T> {
  final String boxName;

  const EntityService(this.boxName);

  Future<void> add(T item, String id) => HiveService.put<T>(boxName, id, item);

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
