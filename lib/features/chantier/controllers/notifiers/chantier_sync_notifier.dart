import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/models/index_model_extention.dart';
import '../../../../models/data/maperror/log_entry.dart';
import '../../../../models/data/state_wrapper/wrappers.dart';
import '../../../../models/notifiers/logged_notifier.dart';
import '../../../../providers/hive_firebase_provider.dart';

class ChantierSyncNotifier extends AsyncNotifier<SyncedState<Chantier>> {
  late Chantier _initial;

  @override
  Future<SyncedState<Chantier>> build() async {
    throw UnimplementedError("Use provider with initial data");
  }

  Future<SyncedState<Chantier>> buildWithInitial(Chantier initial) async {
    _initial = initial;
    return SyncedState.initial(initial);
  }

  Future<void> sync() async {
    final storageService = ref.read(storageServiceProvider);
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(isSyncing: true, hasError: false));
    try {
      final downloadUrl = await storageService.downloadFile(
        'chantier/${current.data.id}/doc_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );

      final updatedChantier = current.data.copyWith(
        etat: 'Synced',
        documents: [
          ...current.data.documents,
          PieceJointe.mock(
            id: DateTime.now().toString(),
            nom: 'Document sync',
            url: downloadUrl,
          ),
        ],
      );
      state = AsyncData(
        current.copyWith(
          data: updatedChantier,
          isSyncing: false,
          lastSynced: DateTime.now(),
        ),
      );
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> syncNow(File file) async {
    final storageService = ref.read(storageServiceProvider);
    final current = state.value;

    if (current == null) return;

    state = AsyncData(current.copyWith(isSyncing: true, hasError: false));

    try {
      final downloadUrl = await storageService.uploadFile(
        file,
        'chantier/${current.data.id}/doc_${DateTime.now().millisecondsSinceEpoch}.pdf',
      );

      final updatedChantier = current.data.copyWith(
        etat: 'Synced',
        documents: [
          ...current.data.documents,
          PieceJointe.mock(
            id: DateTime.now().toString(),
            nom: 'Document sync',
            url: downloadUrl,
          ),
        ],
      );

      state = AsyncData(
        current.copyWith(
          data: updatedChantier,
          isSyncing: false,
          lastSynced: DateTime.now(),
        ),
      );

      // 🔥 log
      ref
          .read(loggerNotifierProvider.notifier)
          .log(
            LogEntry(
              action: 'SYNC_CHANTIER',
              target: 'chantier',
              entityId: updatedChantier.id,
              timestamp: DateTime.now(),
            ),
          );
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

final chantierSyncProvider =
    FutureProvider.family<SyncedState<Chantier>, Chantier>((
      ref,
      chantier,
    ) async {
      return SyncedState.initial(chantier);
    });
