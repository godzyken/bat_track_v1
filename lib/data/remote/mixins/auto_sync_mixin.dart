import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/data/json_model.dart';
import '../../../models/data/state_wrapper/wrappers.dart';

mixin AutoSync<T extends JsonModel> on StateNotifier<SyncedState<T>> {
  Timer? _debounceTimer;
  String? _lastJsonCache;

  Future<void> autoSyncIfChanged(
    T data,
    Future<String> Function(File file) upload,
  ) async {
    final json = jsonEncode(data.toJson());
    if (_lastJsonCache == json) return;
    _lastJsonCache = json;

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      final tempDir = Directory.systemTemp;
      final file = File('${tempDir.path}/${data.id}.json');
      await file.writeAsString(json);
      final url = await upload(file);
      developer.log('🔄 AutoSync : $url');
    });
  }

  void cancelAutoSync() => _debounceTimer?.cancel();
}
