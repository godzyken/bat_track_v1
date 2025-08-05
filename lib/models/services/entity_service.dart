import '../data/json_model.dart';

abstract class EntityService<T extends JsonModel> {
  Future<void> save(T entity, String id);

  Future<void> update(T entity, String id);

  T? getById(String id);

  Future<T?> get(String id);

  Future<void> delete(String id);

  Future<bool> exists(String id);

  Future<List<String>> getKeys();

  Future<List<T>> getAll();

  Future<void> deleteAll();

  Future<void> deleteByQuery(String query);

  Future<List<T>> where(bool Function(T) test);

  Future<List<T>> sortedBy(
    Comparable Function(T) selector, {
    bool descending = false,
  });

  Future<List<T>> query(String query);

  Future<void> closeAll();

  Future<void> open();

  Future<void> init();

  Future<void> clear();

  Stream<List<T>> watchByChantier(String chantierId);
}
