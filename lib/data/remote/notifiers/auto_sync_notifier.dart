import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/entity_sync_services.dart';

class AutoSyncNotifier extends StateNotifier<void> {
  AutoSyncNotifier(this.ref) : super(null) {
    _startAutoSync();
  }

  final Ref ref;

  void _startAutoSync() {
    Timer.periodic(const Duration(minutes: 10), (_) async {
      await syncAllEntitiesFromFirestore(ref);
    });
  }
}

final autoSyncProvider = StateNotifierProvider<AutoSyncNotifier, void>(
  (ref) => AutoSyncNotifier(ref),
);
