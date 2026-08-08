abstract class RemoteStorageService {
  const RemoteStorageService();

  bool get isConnected => true; // Par défaut connecté

  /// 🔍 Récupère un enregistrement brut
  Future<Map<String, dynamic>> getRaw(String collectionOrTable, String id);

  /// 💾 Enregistre ou met à jour
  Future<void> saveRaw(
    String collectionOrTable,
    String id,
    Map<String, dynamic> data,
  );

  /// 🗑 Supprime
  Future<void> deleteRaw(String collectionOrTable, String id);

  /// 📜 Récupère tous les enregistrements
  Future<List<Map<String, dynamic>>> getAllRaw(
    String collectionOrTable, {
    DateTime? updatedAfter,
    int? limit,
  });

  /// 📡 Stream sur une collection/table
  Stream<List<Map<String, dynamic>>> watchCollectionRaw(
    String collectionOrTable, {
    dynamic Function(dynamic query)? queryBuilder,
  });
}
