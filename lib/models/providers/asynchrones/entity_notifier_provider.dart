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

typedef EntityNotifierProviderFamily<T extends UnifiedModel> =
    AsyncNotifierProviderFamily<
      FamilyAsyncNotifier<T?, String>, // Le Notifier gère T?
      T?,
      String // L'ID pour la famille
    >;
