import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_models/shared_models.dart';

import '../providers/auth_state_provider.dart';

class CurrentUserNotifier extends Notifier<AsyncValue<AppUser?>> {
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _sub;

  @override
  AsyncValue<AppUser?> build() {
    final authState = ref.watch(authStateChangesProvider).value;

    if (authState == null) {
      _sub?.cancel();
      return const AsyncData(null);
    }

    final firestore = ref.read(firestoreProvider);

    _sub?.cancel();

    state = const AsyncLoading();

    _sub = firestore
        .collection("users")
        .doc(authState.uid)
        .snapshots()
        .listen(
          (snap) {
            if (!snap.exists) {
              state = const AsyncData(null);
              return;
            }

            final data = _normalize(
              snap.data() ?? {},
              authState.uid,
              authState.displayName,
              authState.email,
            );

            state = AsyncData(AppUser.fromJson(data));
          },
          onError: (e, st) {
            state = AsyncError(e, st);
          },
        );

    return const AsyncLoading();
  }

  void cancel() {
    _sub?.cancel();
  }

  // ----------------------------
  // utils
  // ----------------------------

  Map<String, dynamic> _normalize(
    Map<String, dynamic> data,
    String uid,
    String? name,
    String? email,
  ) {
    final normalized = data.map((k, v) => MapEntry(k, _convert(v)));
    normalized['uid'] = uid;
    normalized.putIfAbsent('name', () => name ?? '');
    normalized.putIfAbsent('email', () => email ?? '');
    return normalized;
  }

  dynamic _convert(dynamic value) {
    if (value is Timestamp) return value.toDate().toIso8601String();
    if (value is Map<String, dynamic>) {
      return value.map((k, v) => MapEntry(k, _convert(v)));
    }
    if (value is List) return value.map(_convert).toList();
    return value;
  }
}
