/*
abstract class EntityService<T extends UnifiedModel> {
  Future<void> save(T entity, String id);

  Future<void> update(T entity, String id);

  Future<T?> getById(String id);

  Future<T?> get(String id);

  Future<void> delete(String id);

  Future<bool> exists(String id);

  Future<List<String>> getKeys();

  Future<List<T>> getAll();
  Future<List<T>> getByQuery(Map<String, dynamic> query);

  Future<void> deleteAll();

  Future<void> deleteByQuery(Map<String, dynamic> query);

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

  Stream<List<T>> watchAll();
  Stream<List<T>> watchByChantier(String chantierId);
  Stream<List<T>> watchByQuery(Map<String, dynamic> query);

  Future<Map<String, dynamic>> getLocalRaw(String id);

  /// Lit la version distante (ex. Firestore)
  Future<Map<String, dynamic>> getRemoteRaw(String id);

  /// Écrit la version distante
  Future<void> saveRemoteRaw(String id, Map<String, dynamic> data);

  /// Écrit la version locale
  Future<void> saveLocalRaw(String id, Map<String, dynamic> data);
}
*/
