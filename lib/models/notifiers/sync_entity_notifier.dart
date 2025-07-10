import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/services/service_type.dart';
import '../../data/remote/services/storage_service.dart';
import '../data/json_model.dart';
import '../data/state_wrapper/wrappers.dart';

class SyncEntityNotifier<T extends JsonModel>
    extends StateNotifier<SyncedState<T>> {
  final EntityService<T> entityService;
  final StorageService storageService;
  Timer? _debounceTimer;

  SyncEntityNotifier({
    required this.entityService,
    required this.storageService,
    required T initialState,
  }) : super(SyncedState(data: initialState));

  Future<void> update(T updated) async {
    state = state.copyWith(data: updated);
    await entityService.save(updated, updated.id!);

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 5), () async {
      await _uploadToFirebaseStorage();
    });
  }

  Future<void> syncNow() async {
    _debounceTimer?.cancel();
    await _uploadToFirebaseStorage();
  }

  Future<void> _uploadToFirebaseStorage() async {
    try {
      state = state.copyWith(isSyncing: true, hasError: false);
      final file = await _saveToTempFile(state.data);
      final url = await storageService.uploadFile(
        file,
        'sync/${state.data.id}.json',
      );
      state = state.copyWith(isSyncing: false, lastSynced: DateTime.now());
      developer.log('✅ Sync réussie : $url');
    } catch (e) {
      state = state.copyWith(isSyncing: false, hasError: true);
      developer.log('❌ Erreur de sync : $e');
    }
  }

  Future<File> _saveToTempFile(T item) async {
    final json = item.toJson();
    final tempDir = Directory.systemTemp;
    final file = File('${tempDir.path}/${item.id}.json');
    await file.writeAsString(jsonEncode(json));
    return file;
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
