import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../../data/core/unified_model.dart';
import '../../notifiers/entity_notifier.dart';
import '../../services/entity_service.dart';

final entityNotifierProviderFamily = <Type, dynamic>{};

StateNotifierProviderFamily<EntityNotifier<T>, T?, String>
createEntityNotifierProvider<T extends UnifiedModel>({
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
