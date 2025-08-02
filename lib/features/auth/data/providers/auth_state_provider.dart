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
final authStateProvider = Provider<User?>((ref) {
  return ref.watch(authStateChangesProvider).asData?.value;
});

/// Charge son profil Firestore
final userProfileProvider = FutureProvider<UserModel?>((ref) async {
  final user = ref.watch(authStateChangesProvider).value;
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
final appUserProvider = FutureProvider<AppUser?>((ref) async {
  final user = ref.watch(authStateProvider);
  if (user == null) return null;

  final snapshot =
      await ref
          .watch(firestoreProvider)
          .collection('users')
          .doc(user.uid)
          .get();

  if (!snapshot.exists) return null;

  return AppUser.fromJson(snapshot.data()!);
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

final currentUserProvider = StreamProvider<AppUser?>((ref) {
  final auth = FirebaseAuth.instance;
  return auth.authStateChanges().asyncMap((user) async {
    if (user == null) return null;
    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
    return doc.exists ? AppUser.fromJson(doc.data()!) : null;
  });
});
