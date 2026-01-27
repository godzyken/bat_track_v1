import 'package:bat_track_v1/data/local/providers/hive_provider.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/models/utilisateurs/app_user.dart';
import '../../../../data/local/models/utilisateurs/user.dart';
import '../notifiers/current_user_notifier.dart';
import 'auth_state_provider.dart';

/// 🔑 Fournit l'utilisateur connecté (AppUser complet, ou null)
final currentUserProvider =
    StreamNotifierProvider.autoDispose<CurrentUserNotifier, AppUser?>(() {
      return CurrentUserNotifier();
    });

/// Fournit l’état global de l’utilisateur (Guest / Auth / Loaded)
final userStatusProvider = Provider<UserStatus>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  final profile = ref.watch(currentUserProvider);

  if (auth.currentUser == null) return UserStatus.guest;
  return profile.maybeWhen(
    data: (user) => user != null ? UserStatus.loaded : UserStatus.authenticated,
    orElse: () => UserStatus.authenticated,
  );
});

/// Fournisseur modifiable en local (ex: ajout instanceId)
final currentUserStateProvider = StateProvider<AppUser?>((ref) {
  return ref.watch(currentUserProvider).value;
});

final currentUserLoaderProvider = FutureProvider<AppUser?>((ref) async {
  final usersAsync = ref.watch(allUsersStreamProvider);

  final users = usersAsync.value;
  if (users == null) {
    return null;
  }

  return users.firstWhereOrNull((user) => user.appIsUpdated == false);
});
