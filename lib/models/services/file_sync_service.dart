/// Service de synchronisation fichiers/entités
/*class FileSyncService<T extends UnifiedModel> {
  final UnifiedEntityService<T> entityService; // Firestore ou Supabase
  final StorageService storageService; // Hive, SQLite ou autre local

  FileSyncService({required this.entityService, required this.storageService});

  /// Télécharge toutes les entités depuis le serveur et les sauvegarde localement
  Future<void> pull({DateTime? updatedAfter, int? limit}) async {
    try {
      developer.log('[SYNC] Pull ${T.toString()}...');

      final raw = await entityService.getAllRaw(
        entityService.collectionName,
        updatedAfter: updatedAfter,
        limit: limit,
      );

      final items = raw.map((map) => entityService.fromJson(map)).toList();

      for (final item in items) {
        await storageService.save(item.toJson() as File, item.id);
      }

      developer.log('[SYNC] Pull terminé: ${items.length} éléments.');
    } catch (e, st) {
      developer.log('[SYNC] Pull error: $e\n$st');
      rethrow;
    }
  }

  /// Pousse toutes les entités locales vers le serveur
  Future<void> push({bool force = false}) async {
    try {
      developer.log('[SYNC] Push ${T.toString()}...');

      final localItems = await storageService.getAll();
      for (final rawItem in localItems) {
        final map =
            rawItem.isNotEmpty
                ? jsonDecode(rawItem) as Map<String, dynamic>
                : rawItem as Map<String, dynamic>;

        final item = entityService.fromJson(map);

        if (force) {
          await entityService.sync(item);
        } else {
          final remote = await entityService.get(item.id);
          if (remote == null ||
              (item.updatedAt != null &&
                  remote.updatedAt != null &&
                  item.updatedAt!.isAfter(remote.updatedAt!))) {
            await entityService.save(item);
          }
        }
      }

      developer.log('[SYNC] Push terminé.');
    } catch (e, st) {
      developer.log('[SYNC] Push error: $e\n$st');
      rethrow;
    }
  }

  /// Merge local et remote avec gestion des conflits basique
  Future<void> merge() async {
    developer.log('[SYNC] Merge ${T.toString()}...');
    await pull();
    await push();
    developer.log('[SYNC] Merge terminé.');
  }
}*/
