import 'package:bat_track_v1/data/local/models/base/has_files.dart';
import 'package:bat_track_v1/data/remote/services/storage_service.dart';
import 'package:bat_track_v1/models/data/json_model.dart';

import 'entity_sync_services.dart';

/// Service de sync + upload pour les entités implémentant HasFile
class FileSyncService<T extends JsonModel> extends EntitySyncService<T> {
  FileSyncService(String boxName) : super(boxName);

  @override
  Future<void> save(T item, {String? id}) async {
    if (item is HasFile) {
      final docId = id ?? item.id;
      // 1. Sauvegarde Hive + Firestore
      await super.save(item, id: docId);
      // 2. Upload du fichier
      final file = (item as HasFile).getFile();
      final fileName = file.path.split('/').last;
      final path = '$boxName/$docId/$fileName';
      await StorageService(storage).uploadFile(file, path);
    } else {
      // fallback si l'entité n'implémente pas HasFile
      await super.save(item, id: id);
    }
  }

  @override
  Future<void> delete(String id) async {
    // Supprime d’abord tous les fichiers dans le dossier
    final dirRef = storage.ref().child(boxName).child(id);
    final listResult = await dirRef.listAll();
    for (var itemRef in listResult.items) {
      await itemRef.delete();
    }
    // Puis supprime Hive + Firestore
    await super.delete(id);
  }
}
