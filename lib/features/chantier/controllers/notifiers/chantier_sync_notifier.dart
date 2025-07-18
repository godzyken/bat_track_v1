import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/models/index_model_extention.dart';
import '../../../../models/data/state_wrapper/wrappers.dart';
import '../../../../providers/hive_firebase_provider.dart';

class ChantierSyncNotifier extends StateNotifier<SyncedState<Chantier>> {
  ChantierSyncNotifier(this.ref, this._initial)
    : super(SyncedState.initial(_initial));

  final Ref ref;
  final Chantier _initial;

  void update(Chantier updated) {
    state = state.copyWith(data: updated);
  }

  Future<void> syncNow() async {
    final chantier = state.data;
    final storageService = ref.read(storageServiceProvider); // ✅ accès ici

    try {
      state = state.copyWith(isSyncing: true, hasError: false);

      // Simule un upload (remplace avec ton vrai fichier + path)
      final file = File('path/to/your/file.pdf');
      final downloadUrl = await storageService.uploadFile(
        file,
        'chantier/${chantier.id}/doc.pdf',
      );

      await Future.delayed(const Duration(seconds: 1)); // simulate delay

      state = state.copyWith(isSyncing: false, lastSynced: DateTime.now());
      update(
        chantier.copyWith(
          etat: 'Synced',
          documents: [
            PieceJointe.mock(id: 'doc1', nom: 'Document 1', url: downloadUrl),
            PieceJointe.mock(id: 'doc2', nom: 'Document 2', url: downloadUrl),
          ],
        ),
      );
    } catch (e) {
      state = state.copyWith(isSyncing: false, hasError: true);
    }
  }
}
