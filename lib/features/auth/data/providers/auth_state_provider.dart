import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/models/index_model_extention.dart';

final firebaseAuthProvider = Provider((ref) => FirebaseAuth.instance);
final firestoreProvider = Provider((ref) => FirebaseFirestore.instance);

/// Le stream qui notifie des changements d'état de connexion
final authStateChangesProvider = StreamProvider<User?>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return auth.authStateChanges();
});

/// Optionnel : l'utilisateur courant (value ou null)
final authStateProvider = StreamProvider<AppUser?>((ref) {
  final auth = ref.read(firebaseAuthProvider); // ✅ use read, not watch
  final firestore = ref.read(firestoreProvider);

  dynamic _convertFirestoreValue(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate().toIso8601String();
    if (value is DocumentReference) return value.path;
    if (value is GeoPoint) {
      return {'lat': value.latitude, 'lng': value.longitude};
    }
    if (value is Map<String, dynamic>) {
      return value.map((k, v) => MapEntry(k, _convertFirestoreValue(v)));
    }
    if (value is List) return value.map(_convertFirestoreValue).toList();
    return value;
  }

  Map<String, dynamic> _normalizeData(
    Map<String, dynamic> data,
    String uid,
    String? name,
    String? email,
  ) {
    final normalized = <String, dynamic>{};
    data.forEach((key, value) {
      normalized[key] = _convertFirestoreValue(value);
    });

    // Champs obligatoires pour AppUser
    normalized['uid'] = uid;
    normalized.putIfAbsent('name', () => name ?? '');
    normalized.putIfAbsent('email', () => email ?? '');
    normalized.putIfAbsent('role', () => 'client');
    normalized.putIfAbsent('company', () => '');

    // ⚠️ createdAt doit rester fixe
    if (!normalized.containsKey('createdAt')) {
      normalized['createdAt'] = DateTime(2000).toIso8601String();
    }

    return normalized;
  }

  return auth.authStateChanges().asyncMap((user) async {
    if (user == null) return null;

    try {
      final doc = await firestore.collection("users").doc(user.uid).get();

      final data = _normalizeData(
        doc.data() ?? {},
        user.uid,
        user.displayName,
        user.email,
      );

      return AppUser.fromJson(data);
    } catch (e, st) {
      developer.log(
        "[AuthStateProvider] Failed to get user doc: $e",
        stackTrace: st,
      );
      return AppUser.empty();
    }
  });
});

/// Charge son profil Firestore
final userProfileProvider = FutureProvider<UserModel?>((ref) async {
  final user = ref.watch(appUserProvider).value;
  if (user == null) return null;
  final doc =
      await ref
          .watch(firestoreProvider)
          .collection('users')
          .doc(user.uid)
          .get();
  if (!doc.exists) return null;
  return UserModel.fromJson(doc.data()!);
});

/// 🔑 Récupère le AppUser (depuis Firestore) pour l'utilisateur connecté
final appUserProvider = StreamProvider<AppUser?>((ref) {
  final auth = ref.watch(authStateChangesProvider).value;
  if (auth == null) return Stream.value(null);

  return FirebaseFirestore.instance
      .collection('users')
      .doc(auth.uid)
      .snapshots()
      .map((snap) {
        final data = snap.data();
        if (data == null) return null;
        return AppUser.fromJson(data);
      });
});

final allUsersProfileProvider = StreamProvider<List<UserModel>>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return firestore.collection('users').snapshots().map((snapshot) {
    return snapshot.docs.map((doc) => UserModel.fromJson(doc.data())).toList();
  });
});

final usersByRoleProvider = FutureProvider.family<List<UserModel>, String>((
  ref,
  role,
) async {
  final firestore = ref.watch(firestoreProvider);
  final query =
      await firestore.collection('users').where('role', isEqualTo: role).get();
  return query.docs.map((doc) => UserModel.fromJson(doc.data())).toList();
});
