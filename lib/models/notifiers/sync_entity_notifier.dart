import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/services/service_type.dart';
import '../../data/remote/services/storage_service.dart';
import '../data/json_model.dart';

class SyncEntityNotifier<T extends JsonModel> extends StateNotifier<T> {
  final EntityService<T> entityService;
  final StorageService storageService;
  Timer? _debounceTimer;

  SyncEntityNotifier({
    required this.entityService,
    required this.storageService,
    required T initialState,
  }) : super(initialState);

  /// Met à jour le contenu localement + déclenche la synchro différée
  Future<void> update(T updated) async {
    state = updated;
    await entityService.save(state, state.id!); // sauvegarde Hive immédiate

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(minutes: 2), () async {
      await _uploadToFirebaseStorage();
    });
  }

  /// Crée un fichier temporaire et envoie dans Firebase Storage
  Future<void> _uploadToFirebaseStorage() async {
    try {
      final file = await _saveToTempFile(state);
      final url = await storageService.uploadFile(
        file,
        'sync/${state.id}.json',
      );

      // Si ton modèle a un champ `firebaseUrl`, tu peux l'ajouter ici
      developer.log('✅ Upload réussi : $url');
    } catch (e) {
      developer.log('❌ Erreur d\'upload : $e');
    }
  }

  Future<File> _saveToTempFile(T item) async {
    final json = item.toJson();
    final tempDir = Directory.systemTemp;
    final file = File('${tempDir.path}/${item.id}.json');
    await file.writeAsString(json.toString()); // ou jsonEncode(json)
    return file;
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
