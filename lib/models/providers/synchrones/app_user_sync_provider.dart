import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/models/utilisateurs/app_user.dart';
import '../../../data/local/providers/hive_provider.dart';
import '../../../providers/hive_firebase_provider.dart';
import '../../data/state_wrapper/wrappers.dart';
import '../../notifiers/sync_entity_notifier.dart';

final appUserSyncProvider =
    StateNotifierProvider<SyncEntityNotifier<AppUser>, SyncedState<AppUser>>((
      ref,
    ) {
      return SyncEntityNotifier<AppUser>(
        entityService: ref.read(appUserEntityServiceProvider),
        storageService: ref.read(storageServiceProvider),
        initialState: AppUser.empty(),
      );
    });
