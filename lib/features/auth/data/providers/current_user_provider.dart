import 'dart:developer' as developer;

import 'package:bat_track_v1/data/local/providers/hive_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/models/utilisateurs/app_user.dart';
import '../../../../data/local/models/utilisateurs/user.dart';
import 'auth_state_provider.dart';

/// 🔑 Fournit l'utilisateur connecté (AppUser complet, ou null)
final currentUserProvider = StreamProvider<AppUser?>((ref) {
  final auth = ref.watch(firebaseAuthProvider);

  dynamic _convert(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate().toIso8601String();
    if (value is DocumentReference) return value.path;
    if (value is GeoPoint) {
      return {'lat': value.latitude, 'lng': value.longitude};
    }
    if (value is Map<String, dynamic>) {
      return value.map((k, v) => MapEntry(k, _convert(v)));
    }
    if (value is List) return value.map(_convert).toList();
    return value;
  }

  Map<String, dynamic> _normalize(
    Map<String, dynamic> data,
    String uid,
    String? name,
    String? email,
  ) {
    final normalized = <String, dynamic>{};
    data.forEach((k, v) => normalized[k] = _convert(v));

    normalized['uid'] = uid;
    normalized.putIfAbsent('name', () => name ?? '');
    normalized.putIfAbsent('email', () => email ?? '');
    normalized.putIfAbsent('role', () => 'client');
    normalized.putIfAbsent('company', () => '');

    if (!normalized.containsKey('createdAt')) {
      normalized['createdAt'] = DateTime(2000).toIso8601String();
    }

    return normalized;
  }

  return auth.authStateChanges().asyncExpand((user) {
    if (user == null) return Stream.value(null);

    return FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .snapshots()
        .map((doc) {
          final data = _normalize(
            doc.data() ?? {},
            user.uid,
            user.displayName,
            user.email,
          );
          return AppUser.fromJson(data);
        })
        .handleError((e, st) {
          developer.log("[currentUserProvider] Error: $e", stackTrace: st);
          return AppUser.empty();
        });
  });
});

/// Fournisseur modifiable en local (ex: ajout instanceId)
final currentUserStateProvider = StateProvider<AppUser?>((ref) {
  return ref.watch(currentUserProvider).value;
});

final currentUserLoaderProvider = FutureProvider<UserModel?>((ref) async {
  final users = ref.watch(allUsersProvider);
  return users.firstWhereOrNull((user) => user.isCloudOnly == false);
});
