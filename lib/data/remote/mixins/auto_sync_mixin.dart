import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_models/core/models/unified_model.dart';

import '../../../models/data/maperror/log_entry.dart';
import '../../../models/data/state_wrapper/wrappers.dart';
import '../../../models/notifiers/logged_notifier.dart';

mixin AutoSync<T extends UnifiedModel, Serializable>
    on Notifier<SyncedState<T>> {
  String? _lastJsonCache;
  int _debounceId = 0;

  Future<void> autoSyncIfChanged(
    T data,
    Future<String> Function(File file) upload,
  ) async {
    final json = jsonEncode(data.toJson());

    // 🧠 skip si pas de changement
    if (_lastJsonCache == json) return;
    _lastJsonCache = json;

    final currentId = ++_debounceId;

    // ⏳ pseudo-debounce sans Timer
    await Future.delayed(const Duration(milliseconds: 500));

    // ❌ si un nouvel update est passé → on annule
    if (currentId != _debounceId) return;

    try {
      final tempDir = Directory.systemTemp;
      final file = File('${tempDir.path}/${data.id}.json');

      await file.writeAsString(json);

      await _safeUpload(() async {
        final url = await upload(file);
        ref
            .read(loggerNotifierProvider.notifier)
            .log(
              LogEntry(
                action: 'auto_sync',
                target: T.toString(),
                data: {'id': data.id, 'url': url},
                timestamp: DateTime.now(),
              ),
            );
      });
    } catch (e, st) {
      ref
          .read(loggerNotifierProvider.notifier)
          .log(
            LogEntry(
              action: 'auto_sync',
              target: T.toString(),
              data: {'id': data.id, 'error': e.toString(), 'stackTrace': st},
              timestamp: DateTime.now(),
            ),
          );
    }
  }

  bool _isUploading = false;

  Future<void> _safeUpload(Future<void> Function() fn) async {
    if (_isUploading) return;
    _isUploading = true;

    try {
      await fn();
    } finally {
      _isUploading = false;
    }
  }

  void cancelAutoSync() {
    _debounceId++; // 🔥 invalide toutes les tâches en attente
  }
}
