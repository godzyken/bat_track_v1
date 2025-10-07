import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:bat_track_v1/data/remote/services/base_storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/models/base/has_acces_control.dart';
import '../../data/remote/services/firebase_storage_service.dart';
import '../../data/remote/services/storage_service.dart';
import '../data/json_model.dart';
import '../data/maperror/proxy.dart';
import '../data/state_wrapper/wrappers.dart';
import '../services/entity_service.dart';

class SyncEntityNotifier<T extends JsonModel>
    extends StateNotifier<SyncedState<T>> {
  final EntityService<T> entityService;
  final BaseStorageService<File> storageService;
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

    if (updated.id.isEmpty) {
      await entityService.save(updated, state.data.id);
    } else {
      await entityService.update(updated, updated.id);
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
      final json = jsonEncode((state.data as JsonSerializableModel).toJson());

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
      _logClickable('✅ Sync réussie', json, extra: {'url': url});
    } catch (e) {
      state = state.copyWith(isSyncing: false, hasError: true);
      developer.log('❌ Erreur de sync : $e');
    }
  }

  Future<File> _saveToTempFile(T item) async {
    final tempDir = Directory.systemTemp;
    final file = File('${tempDir.path}/${item.id}.json');
    await file.writeAsString(jsonEncode(item as JsonSerializableModel));
    return file;
  }

  void _logClickable(
    String message,
    String json, {
    Map<String, dynamic>? extra,
  }) {
    final prettyJson = const JsonEncoder.withIndent(
      '  ',
    ).convert(jsonDecode(json));

    final buffer =
        StringBuffer()
          ..writeln(message)
          ..writeln('---- JSON ----')
          ..writeln(prettyJson)
          ..writeln('--------------');

    if (extra != null) {
      buffer.writeln('Extra: ${jsonEncode(extra)}');
    }

    // Log cliquable (le JSON apparait complet dans la console)
    developer.log(
      buffer.toString(),
      name: 'SyncEntityNotifier<${T.toString()}>',
    );
  }

  Future<void> clearCache() async {
    _lastJsonCache = null;
    await storageService.deleteAllFiles();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

class SyncEntityNotifierDebug<T extends JsonModel>
    extends SyncEntityNotifier<T> {
  SyncEntityNotifierDebug({
    required EntityService<T> entityService,
    required StorageService storageService,
    required T initialState,
    bool autoSync = true,
    MethodFilter? logFilter,
    CallInterceptor? interceptor,
  }) : super(
         entityService:
             DebugProxy<EntityService<T>>(
                   entityService,
                   logFilter: logFilter,
                   interceptor: interceptor,
                 )
                 as EntityService<T>,
         storageService:
             DebugProxy<StorageService>(
                   storageService,
                   logFilter: logFilter,
                   interceptor: interceptor,
                 )
                 as FirebaseStorageService,
         initialState: initialState,
         autoSync: autoSync,
       );
}
