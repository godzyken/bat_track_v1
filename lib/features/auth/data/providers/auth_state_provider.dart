import 'package:bat_track_v1/features/auth/data/providers/current_user_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../data/local/models/index_model_extention.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance,
);

final firestoreProvider = Provider((ref) => FirebaseFirestore.instance);

/// Le stream qui notifie des changements d'état de connexion
final authStateChangesProvider = StreamProvider<User?>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  return auth.authStateChanges();
});

/// Charge son profil Firestore
final userProfileProvider = FutureProvider<UserModel?>((ref) async {
  final user = ref.watch(currentUserProvider).value;
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

/// Fournisseur du flux d'authentification
final firebaseUserProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});
