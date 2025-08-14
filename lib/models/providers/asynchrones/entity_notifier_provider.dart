import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../data/json_model.dart';
import '../../services/entity_service.dart';
import '../../notifiers/entity_notifier.dart';

final entityNotifierProviderFamily = <Type, dynamic>{};

StateNotifierProviderFamily<EntityNotifier<T>, T?, String>
createEntityNotifierProvider<T extends JsonModel>({
  required String hiveBoxName,
  required Provider<EntityService<T>> serviceProvider,
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
}
