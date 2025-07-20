import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/entity_sync_services.dart';

class AutoSyncNotifier extends StateNotifier<void> {
  AutoSyncNotifier(this.ref) : super(null) {
    _startAutoSync();
    _initialSync();
  }

  final Ref ref;
  late final Timer _timer;

  Future<void> _initialSync() async {
    try {
      await syncAllEntitiesFromFirestore(ref);
    } catch (e) {
      developer.log('Initial sync failed: $e');
    }
  }

  void _startAutoSync() {
    _timer = Timer.periodic(const Duration(minutes: 10), (_) async {
      try {
        await syncAllEntitiesFromFirestore(ref);
      } catch (e, stack) {
        developer.log('Auto-sync error: $e', stackTrace: stack);
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}

final autoSyncProvider =
    StateNotifierProvider.autoDispose<AutoSyncNotifier, void>(
      (ref) => AutoSyncNotifier(ref),
    );
