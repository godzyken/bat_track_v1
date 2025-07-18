import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/data/state_wrapper/wrappers.dart';
import '../../../models/notifiers/sync_entity_notifier.dart';
import '../../../providers/hive_firebase_provider.dart';
import '../../local/models/chantier.dart';
import '../../local/providers/hive_provider.dart';

final chantierSyncNotifierProvider = StateNotifierProvider.autoDispose<
  SyncEntityNotifier<Chantier>,
  SyncedState<Chantier>
>((ref) {
  final entityService = ref.watch(chantierServiceProvider);
  final storageService = ref.watch(storageServiceProvider); // à créer si besoin
  final chantier = Chantier.mock(); // ou initialisé autrement
  return SyncEntityNotifier<Chantier>(
    entityService: entityService,
    storageService: storageService,
    initialState: chantier,
  );
});
