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

  dynamic convert(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate().toIso8601String();
    if (value is DocumentReference) return value.path;
    if (value is GeoPoint) {
      return {'lat': value.latitude, 'lng': value.longitude};
    }
    if (value is Map<String, dynamic>) {
      return value.map((k, v) => MapEntry(k, convert(v)));
    }
    if (value is List) return value.map(convert).toList();
    return value;
  }

  Map<String, dynamic> normalize(
    Map<String, dynamic> data,
    String uid,
    String? name,
    String? email,
  ) {
    final normalized = <String, dynamic>{};
    data.forEach((k, v) => normalized[k] = convert(v));

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

  return auth.authStateChanges().asyncExpand((user) async* {
    if (user == null) {
      yield null;
      return;
    }

    final doc = FirebaseFirestore.instance.collection("users").doc(user.uid);

    yield* doc
        .snapshots()
        .map((snap) {
          final data = normalize(
            snap.data() ?? {},
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

/// Fournit l’état global de l’utilisateur (Guest / Auth / Loaded)
final userStatusProvider = Provider<UserStatus>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  final currentUser = ref.watch(currentUserProvider);

  if (auth.currentUser == null) return UserStatus.guest;
  if (currentUser.isLoading) return UserStatus.authenticated;
  if (currentUser.hasValue && currentUser.value != null) {
    return UserStatus.loaded;
  }
  return UserStatus.authenticated;
});

/// Fournisseur modifiable en local (ex: ajout instanceId)
final currentUserStateProvider = StateProvider<AppUser?>((ref) {
  return ref.watch(currentUserProvider).value;
});

final currentUserLoaderProvider = FutureProvider<AppUser?>((ref) async {
  final usersAsync = ref.watch(allUsersStreamProvider);

  final users = usersAsync.value;
  if (users == null) {
    return null;
  }

  return users.firstWhereOrNull((user) => user.appIsUpdated == false);
});
