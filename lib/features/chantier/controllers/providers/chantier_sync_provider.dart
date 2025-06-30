import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/local/models/index_model_extention.dart';
import '../../../../data/local/providers/hive_provider.dart';
import '../../../../models/notifiers/sync_entity_notifier.dart';

final chantierInitialProvider = FutureProvider.family<Chantier, String>((
  ref,
  id,
) async {
  final chantierService = ref.watch(chantierServiceProvider);
  final chantier = await chantierService.get(id);

  return chantier ??
      Chantier(
        id: id,
        nom: '',
        adresse: '',
        clientId: '',
        dateDebut: DateTime.now(),
      );
});

final chantierSyncProvider = StateNotifierProvider.family
    .autoDispose<SyncEntityNotifier<Chantier>, Chantier, String>((ref, id) {
      throw UnimplementedError(
        'Utilise chantierSyncControllerProvider pour charger avec données.',
      );
    });
