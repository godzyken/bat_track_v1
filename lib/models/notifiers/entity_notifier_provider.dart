import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../data/local/services/service_type.dart';
import '../data/json_model.dart';
import 'entity_notifier.dart';

final entityNotifierProviderFamily = <Type, dynamic>{};

StateNotifierProviderFamily<EntityNotifier<T>, T?, String>
createEntityNotifierProvider<T extends JsonModel>({
  required String hiveBoxName,
  required EntityService<T> service,
}) {
  final provider = StateNotifierProvider.family<EntityNotifier<T>, T?, String>((
    ref,
    id,
  ) {
    final box = Hive.box<T>(hiveBoxName);
    return EntityNotifier<T>(id: id, box: box, service: service);
  });

  // Memoize for optional reuse
  entityNotifierProviderFamily[T] = provider;

  return provider;
}
