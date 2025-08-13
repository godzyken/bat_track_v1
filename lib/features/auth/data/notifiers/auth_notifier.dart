import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/models/utilisateurs/app_user.dart';

class AuthNotifier extends ChangeNotifier {
  AuthNotifier(this._ref) {
    _ref.listen<AsyncValue<AppUser?>>(authStateNotifierProvider, (
      previous,
      next,
    ) {
      if (previous?.value?.uid != next.value?.uid) {
        notifyListeners();
      }
    });
  }

  final Ref _ref;
}

final authNotifierProvider = Provider<AuthNotifier>((ref) => AuthNotifier(ref));

class AuthState {
  final User? user;
  final bool loading;
  final String? error;

  AuthState({this.user, this.loading = false, this.error});

  AuthState copyWith({User? user, bool? loading, String? error}) {
    return AuthState(
      user: user ?? this.user,
      loading: loading ?? this.loading,
      error: error,
    );
  }
}

class AuthStateNotifier extends AutoDisposeAsyncNotifier<AppUser?> {
  late final FirebaseAuth _auth;
  late final FirebaseFirestore _firestore;

  @override
  Future<AppUser?> build() async {
    _auth = FirebaseAuth.instance;
    _firestore = FirebaseFirestore.instance;

    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (doc.exists) {
      return AppUser.fromJson(doc.data()!);
    } else {
      return null;
    }
  }

  /// Inscription avec création du AppUser dans Firestore
  Future<UserCredential?> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required String role,
    required String company,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception("Utilisateur non trouvé après inscription");
      }

      final appUser = AppUser(
        uid: user.uid,
        email: email,
        name: name,
        role: role,
        company: company,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(user.uid).set(appUser.toJson());

      // Recharge l'état
      state = AsyncValue.data(appUser);
      return userCredential;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  /// Connexion + chargement du AppUser Firestore
  Future<UserCredential?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception("Utilisateur introuvable après connexion");
      }

      final doc = await _firestore.collection('users').doc(user.uid).get();
      final appUser = AppUser.fromJson(doc.data()!);

      state = AsyncValue.data(appUser);
      return userCredential;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  /// Déconnexion
  Future<void> signOut() async {
    await _auth.signOut();
    state = const AsyncValue.data(null);
  }

  /// Recharge manuelle
  Future<void> reload() async {
    final user = _auth.currentUser;
    if (user == null) {
      state = const AsyncValue.data(null);
      return;
    }

    state = const AsyncValue.loading();
    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      final appUser = AppUser.fromJson(doc.data()!);
      state = AsyncValue.data(appUser);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final authStateNotifierProvider =
    AutoDisposeAsyncNotifierProvider<AuthStateNotifier, AppUser?>(
      AuthStateNotifier.new,
    );

/// Notifier pour rafraîchir le GoRouter quand auth change
class GoRouterRefreshNotifier extends ChangeNotifier {
  GoRouterRefreshNotifier(this.ref) {
    ref.listen<AsyncValue<AppUser?>>(authStateNotifierProvider, (
      previous,
      next,
    ) {
      if (previous?.value?.uid != next.value?.uid) {
        notifyListeners();
      }
    });
  }

  final Ref ref;
}

final goRouterRefreshNotifierProvider = Provider<GoRouterRefreshNotifier>((
  ref,
) {
  return GoRouterRefreshNotifier(ref);
});
