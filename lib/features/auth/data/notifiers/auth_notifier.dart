import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../data/local/models/utilisateurs/app_user.dart';

//part 'auth_notifier.g.dart';

@riverpod
class AuthNotifier extends AutoDisposeAsyncNotifier<AppUser?> {
  late final FirebaseAuth _auth;
  late final FirebaseFirestore _firestore;

  // 🔹 Normalisation Firestore
  dynamic _convertFirestoreValue(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate().toIso8601String();
    if (value is DocumentReference) return value.path;
    if (value is GeoPoint)
      return {'lat': value.latitude, 'lng': value.longitude};
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
    normalized.putIfAbsent('createdAt', () => DateTime.now().toIso8601String());

    return normalized;
  }

  @override
  Future<AppUser?> build() async {
    _auth = FirebaseAuth.instance;
    _firestore = FirebaseFirestore.instance;

    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore.collection("users").doc(user.uid).get();
      final data = _normalizeData(
        doc.data() ?? {},
        user.uid,
        user.displayName,
        user.email,
      );
      return AppUser.fromJson(data);
    } catch (e, st) {
      developer.log("[AuthNotifier] build() failed: $e", stackTrace: st);
      return AppUser.empty();
    }
  }

  /// 🔹 Inscription
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

      state = AsyncValue.data(appUser);
      return userCredential;
    } on FirebaseAuthException catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
    return null;
  }

  /// 🔹 Connexion
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
      if (user == null)
        throw Exception("Utilisateur introuvable après connexion");

      final doc = await _firestore.collection('users').doc(user.uid).get();
      final data = _normalizeData(
        doc.data() ?? {},
        user.uid,
        user.displayName,
        user.email,
      );

      final appUser = AppUser.fromJson(data);
      state = AsyncValue.data(appUser);

      return userCredential;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  /// 🔹 Déconnexion
  Future<void> signOut() async {
    await _auth.signOut();
    state = const AsyncValue.data(null);
  }

  /// 🔹 Recharge manuelle
  Future<void> reload() async {
    final user = _auth.currentUser;
    if (user == null) {
      state = const AsyncValue.data(null);
      return;
    }

    state = const AsyncValue.loading();
    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) {
        state = const AsyncValue.data(null);
        return;
      }

      final data = _normalizeData(
        doc.data() ?? {},
        user.uid,
        user.displayName,
        user.email,
      );

      final appUser = AppUser.fromJson(data);
      state = AsyncValue.data(appUser);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final authNotifierProvider =
    AutoDisposeAsyncNotifierProvider<AuthNotifier, AppUser?>(AuthNotifier.new);

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

/// Notifier pour rafraîchir le GoRouter quand auth change
class GoRouterRefreshNotifier extends ChangeNotifier {
  GoRouterRefreshNotifier(this.ref) {
    ref.listen<AsyncValue<AppUser?>>(authNotifierProvider, (previous, next) {
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
