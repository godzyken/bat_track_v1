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
  final auth = ref.watch(firebaseAuthProvider);

  return auth.authStateChanges().asyncMap((user) async {
    if (user == null) return null;

    final doc =
        await ref
            .watch(firestoreProvider)
            .collection('users')
            .doc(user.uid)
            .get();
    return AppUser.fromJson(doc.data()!..['uid'] = user.uid);
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
