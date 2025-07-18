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
  final EntityServices<T> entityService;
  final StorageService storageService;
  final bool autoSync;
  Timer? _debounceTimer;
  String? _lastJsonCache;

  SyncEntityNotifier({
    required this.entityService,
    required this.storageService,
    required T initialState,
    this.autoSync = true,
  }) : super(SyncedState(data: initialState));

  Future<void> update(T updated) async {
    state = state.copyWith(data: updated);

    if (updated.id == null) {
      await entityService.save(updated, state.data.id!);
    } else {
      await entityService.update(updated, updated.id!);
    }

    if (autoSync) {
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
        await _uploadToFirebaseStorage();
      });
    }
  }

  Future<void> syncNow() async {
    _debounceTimer?.cancel();
    await _uploadToFirebaseStorage();
  }

  Future<void> _uploadToFirebaseStorage() async {
    try {
      final json = jsonEncode(state.data.toJson());

      if (_lastJsonCache == json) {
        state = state.copyWith(isSyncing: false);
        return;
      }
      _lastJsonCache = json;

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
    final tempDir = Directory.systemTemp;
    final file = File('${tempDir.path}/${item.id}.json');
    await file.writeAsString(jsonEncode(item.toJson()));
    return file;
  }

  Future<void> clearCache() async {
    _lastJsonCache = null;
    await storageService.clearCache();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
