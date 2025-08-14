import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/providers/hive_provider.dart';
import '../../../providers/hive_firebase_provider.dart';
import '../../data/json_model.dart';
import '../../data/state_wrapper/wrappers.dart';
import '../../notifiers/sync_entity_notifier.dart';

class GenericEntityProviderFactory {
  GenericEntityProviderFactory._();

  static final instance = GenericEntityProviderFactory._();

  final Map<String, dynamic> _providerCache = {};

  /// Provider pour un [SyncEntityNotifier<T>] avec cache
  AutoDisposeStateNotifierProvider<SyncEntityNotifier<T>, SyncedState<T>>
  getSyncEntityNotifierProvider<T extends JsonModel>(String id) {
    final key = 'SyncEntityNotifier<${T.toString()}>::$id';

    if (_providerCache.containsKey(key)) {
      return _providerCache[key]
          as AutoDisposeStateNotifierProvider<
            SyncEntityNotifier<T>,
            SyncedState<T>
          >;
    }

    final initialEntityProvider = FutureProvider.autoDispose.family<T?, String>(
      (ref, id) {
        final service = ref.read(entityServiceProvider<T>());
        return service.getById(id);
      },
    );

    final provider = StateNotifierProvider.autoDispose<
      SyncEntityNotifier<T>,
      SyncedState<T>
    >((ref) {
      final service = ref.read(entityServiceProvider<T>());
      final storage = ref.read(storageServiceProvider);

      final initialData = ref.watch(initialEntityProvider(id)).value;
      if (initialData == null) {
        return SyncEntityNotifier<T>(
          entityService: service,
          storageService: storage,
          initialState: initialData?.copyWithId(id),
          autoSync: false,
        );
      }

      return SyncEntityNotifier<T>(
        entityService: service,
        storageService: storage,
        initialState: initialData,
      );
    });

    _providerCache[key] = provider;
    return provider;
  }

  /// Provider pour liste d'entités [T], avec filtre optionnel
  AutoDisposeFutureProvider<List<T>>
  getEntityListProvider<T extends JsonModel>([Map<String, dynamic>? filter]) {
    final key = 'EntityList<${T.toString()}>::${filter?.toString() ?? 'all'}';

    if (_providerCache.containsKey(key)) {
      return _providerCache[key] as AutoDisposeFutureProvider<List<T>>;
    }

    final provider = FutureProvider.autoDispose<List<T>>((ref) async {
      final service = ref.read(entityServiceProvider<T>());
      final all = await service.getAll();
      if (filter == null) return all;

      return all.where((item) {
        for (final entry in filter.entries) {
          final value = item.copyWithId(key)[entry.key];
          if (value != entry.value) return false;
        }
        return true;
      }).toList();
    });

    _providerCache[key] = provider;
    return provider;
  }

  void clearCache() => _providerCache.clear();
}

extension RefX on WidgetRef {
  AutoDisposeStateNotifierProvider<SyncEntityNotifier<T>, SyncedState<T>>
  syncEntity<T extends JsonModel<T>>(String id) => GenericEntityProviderFactory
      .instance
      .getSyncEntityNotifierProvider<T>(id);
}
