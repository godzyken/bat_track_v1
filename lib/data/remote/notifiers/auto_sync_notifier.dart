import 'dart:async';
import 'dart:developer' as developer;

import 'package:bat_track_v1/models/controllers/states/auto_sync_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/data/maperror/log_entry.dart';
import '../../../models/notifiers/logged_notifier.dart';
import '../../../models/services/entity_sync_services.dart';

class AutoSyncNotifier extends Notifier<AutoSyncState> {
  DateTime? _lastSync;

  @override
  AutoSyncState build() {
    _initialSync();
    return const AutoSyncState();
  }

  Future<void> _runSync({bool silent = false}) async {
    try {
      if (!silent) {
        state = state.copyWith(isSyncing: true, lastError: null);
      }

      await syncAllEntitiesFromFirestore(ref);

      state = state.copyWith(isSyncing: false, lastSync: DateTime.now());

      _log('sync_success');
    } catch (e, st) {
      state = state.copyWith(isSyncing: false, lastError: e);

      _log('sync_error', data: {'error': e.toString()});
      developer.log('Auto-sync error: $e', stackTrace: st);
    }
  }

  Future<void> _initialSync() async {
    await _runSync();
  }

  Future<void> syncNow() async {
    final now = DateTime.now();

    if (_lastSync != null &&
        now.difference(_lastSync!) < const Duration(minutes: 5)) {
      return;
    }
    _lastSync = now;

    await _runSync();
  }

  Future<void> retry() async {
    if (state.lastError != null) {
      await _runSync();
    }
  }

  void _log(String action, {Map<String, dynamic>? data}) {
    ref
        .read(loggerNotifierProvider.notifier)
        .log(
          LogEntry(
            action: action,
            target: 'AutoSync',
            data: data,
            timestamp: DateTime.now(),
          ),
        );
  }
}

final autoSyncProvider =
    NotifierProvider.autoDispose<AutoSyncNotifier, AutoSyncState>(
      AutoSyncNotifier.new,
    );
