import 'package:bat_track_v1/features/auth/data/providers/auth_state_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_models/shared_models.dart';

import '../providers/current_user_provider.dart';

class AuthNotifier extends AsyncNotifier<AppUser?> {
  @override
  Future<AppUser?> build() async {
    // source unique de vérité
    return _loadCurrentUser();
  }

  Future<AppUser?> _loadCurrentUser() async {
    final firebaseUser = ref.read(firebaseAuthProvider).currentUser;

    if (firebaseUser == null) return null;

    try {
      final result = ref.read(currentUserProvider);
      return result.mapOrNull();
    } catch (_) {
      return null;
    }
  }

  // -------------------------------------------------
  // SIGN UP
  // -------------------------------------------------

  Future<UserCredential?> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required String role,
    required String company,
  }) async {
    state = const AsyncLoading();

    try {
      final credential = await ref
          .read(firebaseAuthProvider)
          .createUserWithEmailAndPassword(email: email, password: password);

      state = AsyncData(await _loadCurrentUser());

      return credential;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }

  // -------------------------------------------------
  // SIGN IN
  // -------------------------------------------------

  Future<void> signIn(String email, String password) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await ref
          .read(firebaseAuthProvider)
          .signInWithEmailAndPassword(email: email, password: password);

      return _loadCurrentUser();
    });
  }

  // -------------------------------------------------
  // SIGN OUT
  // -------------------------------------------------

  Future<void> signOut() async {
    await ref.read(firebaseAuthProvider).signOut();
    state = const AsyncData(null);
  }

  // -------------------------------------------------
  // REFRESH EXPLICITE
  // -------------------------------------------------

  Future<void> reload() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_loadCurrentUser);
  }
}
