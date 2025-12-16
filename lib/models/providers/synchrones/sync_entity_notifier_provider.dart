import 'package:bat_track_v1/data/local/models/index_model_extention.dart';
import 'package:bat_track_v1/models/data/state_wrapper/wrappers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/entity_providers.dart';
import '../../../providers/hive_firebase_provider.dart';
import '../../notifiers/sync_entity_notifier.dart';
import '../../notifiers/sync_entity_notifier_loger.dart';

final syncEntityNotifierProvider = StateNotifierProvider<
  SyncEntityNotifierLogger<AppUser>,
  SyncedState<AppUser>
>((ref) {
  final notifier = SyncEntityNotifier<AppUser>(
    entityService: ref.read(
      entityServiceProvider<AppUser>(
        collectionName: 'app_user',
        fromJson: (json) => AppUser.fromJson(json),
      ),
    ),
    storageService: ref.read(storageServiceProvider),
    initialState: AppUser.empty(),
  );
  return SyncEntityNotifierLogger(notifier);
});
