/*final entityNotifierProviderFamily = <Type, dynamic>{};

StateNotifierProviderFamily<EntityNotifier<T>, T?, String>
createEntityNotifierProvider<T extends UnifiedModel>({
  required String hiveBoxName,
  required Provider<UnifiedEntityService<T>> serviceProvider,
}) {
  final provider = StateNotifierProvider.family<EntityNotifier<T>, T?, String>((
    ref,
    id,
  ) {
    final box = Hive.box<T>(hiveBoxName);
    final service = ref.read(serviceProvider);
    return EntityNotifier<T>(id: id, box: box, service: service);
  });

  // Memorize for optional reuse
  entityNotifierProviderFamily[T] = provider;

  return provider;
}*/

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/core/unified_model.dart';
import '../../data/hive_model.dart';
import '../../notifiers/sync_entity_notifier.dart';

typedef EntityNotifierProviderFamily<
  M extends UnifiedModel,
  E extends HiveModel<M>
> =
    AsyncNotifierProviderFamily<
      SyncEntityNotifier<M, E>, // On précise le type exact du Notifier ici
      M?, // Le type de donnée (AsyncValue<M?>)
      String // L'argument (ID)
    >;
