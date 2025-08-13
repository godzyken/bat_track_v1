import 'dart:developer' as developer;

import '../../data/local/services/service_type.dart';
import '../../data/remote/services/storage_service.dart';
import '../data/json_model.dart';

/// Service de synchronisation fichiers/entités
class FileSyncService<T extends JsonModel> {
  final EntityServices<T> entityService; // Firestore ou Supabase
  final StorageService storageService; // Hive, SQLite ou autre local

  FileSyncService({required this.entityService, required this.storageService});

  /// Télécharge toutes les entités depuis le serveur et les sauvegarde localement
  Future<void> pull({DateTime? updatedAfter, int? limit}) async {
    try {
      developer.log('[SYNC] Pull ${T.toString()}...');

      final raw = await entityService.getAllRaw(
        entityService.boxName,
        updatedAfter: updatedAfter,
        limit: limit,
      );

      final items = raw.map((map) => entityService.fromJson(map)).toList();

      for (final item in items) {
        await storageService.save(item.id, item.toJson());
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
      for (final map in localItems) {
        final item = entityService.fromJson(map);

        if (force) {
          await entityService.update(item, item.id);
        } else {
          final remote = await entityService.getById(item.id);
          if (remote == null ||
              (item.updatedAt != null &&
                  remote.updatedAt != null &&
                  item.updatedAt!.isAfter(remote.updatedAt!))) {
            await entityService.update(item, item.id);
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
}
