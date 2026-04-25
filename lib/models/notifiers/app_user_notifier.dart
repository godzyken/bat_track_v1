import 'dart:async';

import 'package:bat_track_v1/models/notifiers/sync_entity_notifier.dart';
import 'package:shared_models/shared_models.dart';

import '../../data/local/models/entities/app_user_entity.dart';
import '../../data/local/providers/hive_provider.dart';
import '../services/logged_entity_service.dart';

class AppUserNotifier extends SyncEntityNotifier<AppUser, AppUserEntity> {
  @override
  FutureOr<AppUser?> build() async {
    // Récupère l'utilisateur via le service (Hive first)
    return await ref.watch(appUserEntityServiceProvider).get(id);
  }

  FutureOr<AppUser?> buildId(String id) async {
    // Récupère l'utilisateur via le service (Hive first)
    return await ref.read(appUserEntityServiceProvider).get(id);
  }

  @override
  SafeAndLoggedEntityService<AppUser, AppUserEntity> get service =>
      ref.read(appUserEntityServiceProvider);

  @override
  Future<void> refreshRemote() async {
    await service.getAllRemote();
  }

  @override
  Future<void> updateEntity(AppUser model) async {
    await service.sync(model);
  }

  // Ajoute ici tes méthodes spécifiques (updateProfile, etc.)
}
