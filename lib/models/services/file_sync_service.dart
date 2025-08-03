import 'dart:developer' as developer;
import 'dart:io';

import 'package:bat_track_v1/data/local/models/base/has_files.dart';
import 'package:bat_track_v1/data/remote/services/storage_service.dart';
import 'package:bat_track_v1/models/data/json_model.dart';

import 'entity_sync_services.dart';

/// Service de sync + upload pour les entités implémentant HasFile
class FileSyncService<T extends JsonModel> extends EntitySyncService<T> {
  FileSyncService(super.boxName);

  @override
  Future<void> save(T item, {String? id}) async {
    final sw = Stopwatch()..start();
    final docId = id ?? item.id;

    developer.log('💾 [FileSync:$boxName] Sauvegarde de $docId démarrée');

    // 1. Sauvegarde Hive + Firestore
    await super.save(item, id: docId);

    // 2. Gestion du fichier s’il y en a un
    if (item is HasFile) {
      final fileItem = item as HasFile; // ✅ Cast explicite
      final file = fileItem.getFile();
      final fileName = file.path.split('/').last;
      final path = '$boxName/$docId/$fileName';

      // Vérifie si un upload est nécessaire
      final shouldUpload = await _shouldUploadFile(path, file);
      if (shouldUpload) {
        developer.log('⬆️ Upload fichier $fileName vers $path');
        await StorageService(storage).uploadFile(file, path);
      } else {
        developer.log('⚠️ Skip upload : fichier $fileName inchangé');
      }
    }

    sw.stop();
    developer.log(
      '✅ [FileSync:$boxName] Sauvegarde terminée en ${sw.elapsedMilliseconds}ms',
    );
  }

  @override
  Future<void> delete(String id) async {
    final sw = Stopwatch()..start();
    developer.log('🗑 Suppression de $boxName/$id + fichiers');

    try {
      final dirRef = storage.ref().child(boxName).child(id);
      final listResult = await dirRef.listAll();

      for (var itemRef in listResult.items) {
        developer.log('🗑️ Suppression fichier: ${itemRef.fullPath}');
        await itemRef.delete();
      }
    } catch (e) {
      developer.log('⚠️ Erreur suppression fichiers Firebase Storage: $e');
    }

    await super.delete(id);

    sw.stop();
    developer.log('✅ Suppression $id terminée en ${sw.elapsedMilliseconds}ms');
  }

  Future<bool> _shouldUploadFile(String path, File file) async {
    try {
      final ref = storage.ref(path);
      final metadata = await ref.getMetadata();
      final cloudUpdated = metadata.updated;
      final localModified = await file.lastModified();

      if (cloudUpdated != null) {
        // Compare les timestamps avec un delta de 1 seconde pour éviter les faux positifs
        return localModified.difference(cloudUpdated).inSeconds.abs() > 1;
      }
      return true; // Pas de métadonnées -> probablement fichier absent => upload
    } catch (e) {
      // Fichier non trouvé ou autre erreur → upload forcé
      return true;
    }
  }
}
