import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/models/utilisateurs/app_user.dart';
import '../providers/auth_state_provider.dart';

class CurrentUserNotifier extends AutoDisposeAsyncNotifier<AppUser?> {
  @override
  Future<AppUser?> build() async {
    final authState = ref.watch(authStateChangesProvider).value;

    if (authState == null) return null;

    // On écoute le flux Firestore
    final stream = ref
        .watch(firestoreProvider)
        .collection("users")
        .doc(authState.uid)
        .snapshots();

    // On transforme le flux en Future pour le build initial,
    // puis on gère les mises à jour via le stream.
    return stream.map((snap) {
      if (!snap.exists) return AppUser.empty();
      return AppUser.fromJson(
        _normalize(
          snap.data() ?? {},
          authState.uid,
          authState.displayName,
          authState.email,
        ),
      );
    }).first;
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

// Définition du Provider
final currentUserProvider =
    AsyncNotifierProvider.autoDispose<CurrentUserNotifier, AppUser?>(() {
      return CurrentUserNotifier();
    });
