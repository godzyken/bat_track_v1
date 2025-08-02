import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_state_provider.dart';

class AuthRepository {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  AuthRepository(this.auth, this.firestore);

  Future<void> signIn(String email, String password) async {
    final userCred = await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    await _createUserIfNeeded(userCred.user);
  }

  Future<void> register(
    String email,
    String password,
    String name,
    String societe,
  ) async {
    final userCred = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = userCred.user;
    if (user != null) {
      await firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'name': name,
        'société': societe,
        'rôle': 'tech', // par défaut
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> _createUserIfNeeded(User? user) async {
    if (user == null) return;
    final doc = firestore.collection('users').doc(user.uid);
    final snapshot = await doc.get();
    if (!snapshot.exists) {
      await doc.set({
        'uid': user.uid,
        'name': user.email?.split('@').first ?? '',
        'société': '',
        'rôle': 'tech',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> signOut() async => auth.signOut();
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(
    ref.watch(firebaseAuthProvider),
    ref.watch(firestoreProvider),
  ),
);
