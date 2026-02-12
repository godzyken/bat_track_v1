import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_models/shared_models.dart';

import '../providers/auth_state_provider.dart';
import '../providers/current_user_provider.dart';

@riverpod
class AuthNotifier extends AutoDisposeAsyncNotifier<AppUser?> {
  @override
  Future<AppUser?> build() async {
    // Initialisation identique à currentUserProvider ou récupération via ref.watch
    return ref.watch(currentUserProvider.future);
  }

  Future<UserCredential?> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required String role,
    required String company,
  }) async {
    state = const AsyncValue.loading();
    try {
      final credential = await ref
          .read(firebaseAuthProvider)
          .createUserWithEmailAndPassword(email: email, password: password);
      // Le state sera mis à jour via le build() et le stream de Firebase
      return credential;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final res = await ref
          .read(firebaseAuthProvider)
          .signInWithEmailAndPassword(email: email, password: password);
      // Le build() sera automatiquement déclenché par le changement d'auth
      return ref.read(currentUserProvider.future);
    });
  }

  Future<void> signOut() async {
    await ref.read(firebaseAuthProvider).signOut();
  }

  /// 🔹 Recharge manuelle
  /*
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
*/
}
