import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../data/local/models/utilisateurs/app_user.dart';
import '../providers/auth_state_provider.dart';
import '../providers/current_user_provider.dart';

@riverpod
class AuthNotifier extends AutoDisposeAsyncNotifier<AppUser?> {
  @override
  Future<AppUser?> build() async {
    // Initialisation identique à currentUserProvider ou récupération via ref.watch
    return ref.watch(currentUserProvider.future);
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
  /*  Future<void> reload() async {
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
  }*/
}

final authNotifierProvider =
    AsyncNotifierProvider.autoDispose<AuthNotifier, AppUser?>(AuthNotifier.new);

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
