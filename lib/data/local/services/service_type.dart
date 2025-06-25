import '../models/index_model_extention.dart';
import 'hive_service.dart';

class EntityService<T> {
  final String boxName;

  const EntityService(this.boxName);

  Future<void> add(T item, String id) => HiveService.put<T>(boxName, id, item);

  Future<void> delete(String id) => HiveService.delete<T>(boxName, id);

  Future<List<T>> getAll() => HiveService.getAll<T>(boxName);

  Future<T?> get(String id) => HiveService.get<T>(boxName, id);

  Future<bool> exists(String id) => HiveService.exists<T>(boxName, id);

  Future<List<String>> getKeys() => HiveService.getKeys<T>(boxName);
}

final chantierService = EntityService<Chantier>('chantiers');
final clientService = EntityService<Client>('clients');
final technicienService = EntityService<Technicien>('techniciens');
final interventionService = EntityService<Intervention>('interventions');
