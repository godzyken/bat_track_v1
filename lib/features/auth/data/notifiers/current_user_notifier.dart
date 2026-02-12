import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_models/shared_models.dart';

import '../providers/auth_state_provider.dart';

class CurrentUserNotifier extends AutoDisposeStreamNotifier<AppUser?> {
  @override
  Stream<AppUser?> build() {
    // 1. On surveille l'état de l'auth
    final authState = ref.watch(authStateChangesProvider).value;

    // Si pas d'utilisateur connecté, on renvoie un flux vide (null)
    if (authState == null) {
      return Stream.value(null);
    }

    // 2. On retourne directement le flux Firestore transformé
    return ref
        .watch(firestoreProvider)
        .collection("users")
        .doc(authState.uid)
        .snapshots()
        .map((snap) {
          if (!snap.exists) return AppUser.empty();

          return AppUser.fromJson(
            _normalize(
              snap.data() ?? {},
              authState.uid,
              authState.displayName,
              authState.email,
            ),
          );
        });
  }

  // Méthode de normalisation privée pour nettoyer le code
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
