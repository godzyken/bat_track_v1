import 'dart:async';

import 'package:bat_track_v1/models/notifiers/sync_entity_notifier.dart';

import '../../data/local/models/entities/app_user_entity.dart';
import '../../data/local/models/utilisateurs/app_user.dart';
import '../../data/local/providers/hive_provider.dart';
import '../services/logged_entity_service.dart';

class AppUserNotifier extends SyncEntityNotifier<AppUser, AppUserEntity> {
  @override
  FutureOr<AppUser?> build(String id) async {
    // Récupère l'utilisateur via le service (Hive first)
    return await ref.watch(appUserEntityServiceProvider).get(id);
  }

  @override
  SafeAndLoggedEntityService<AppUser, AppUserEntity> get service =>
      ref.read(appUserEntityServiceProvider);

  @override
  Future<void> refreshRemote() {
    // TODO: implement refreshRemote
    throw UnimplementedError();
  }

  @override
  Future<void> updateEntity(AppUser model) {
    // TODO: implement updateEntity
    throw UnimplementedError();
  }

  // Ajoute ici tes méthodes spécifiques (updateProfile, etc.)
}
