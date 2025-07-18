import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/local/providers/hive_provider.dart';
import '../../../providers/hive_firebase_provider.dart';
import '../../data/json_model.dart';
import '../../data/state_wrapper/wrappers.dart';
import '../../notifiers/sync_entity_notifier.dart';

final _syncEntityProviderCache = <String, dynamic>{};

final syncEntityNotifierProvider =
    <T extends JsonModel>(String id) => StateNotifierProvider.autoDispose<
      SyncEntityNotifier<T>,
      SyncedState<T>
    >((ref) {
      final key = '${T.toString()}::_$id';
      if (_syncEntityProviderCache.containsKey(key)) {
        return _syncEntityProviderCache[key] as SyncEntityNotifier<T>;
      }

      final service = ref.read(entityServiceProvider<T>());
      final storage = ref.read(storageServiceProvider);

      final initialData = service.getById(id);
      if (initialData == null) throw Exception('Entity with ID $id not found');
      _syncEntityProviderCache[key] = SyncEntityNotifier<T>(
        entityService: service,
        storageService: storage,
        initialState: initialData,
      );

      return SyncEntityNotifier<T>(
        entityService: service,
        storageService: storage,
        initialState: initialData,
      );
    });

final createSyncEntityNotifierProvider =
    <T extends JsonModel>({required String id}) =>
        StateNotifierProvider.autoDispose<
          SyncEntityNotifier<T>,
          SyncedState<T>
        >((ref) {
          final key = '${T.toString()}::_$id';
          if (_syncEntityProviderCache.containsKey(key)) {
            return _syncEntityProviderCache[key] as SyncEntityNotifier<T>;
          }

          final service = ref.read(entityServiceProvider<T>());
          final storage = ref.read(storageServiceProvider);

          final initialData = service.getById(id);
          if (initialData == null) {
            throw Exception('Entity with ID $id not found');
          }

          _syncEntityProviderCache[key] = SyncEntityNotifier<T>(
            entityService: service,
            storageService: storage,
            initialState: initialData,
          );

          return SyncEntityNotifier<T>(
            entityService: service,
            storageService: storage,
            initialState: initialData,
          );
        });

class GenericEntityProviderFactory {
  GenericEntityProviderFactory._privateConstructor();

  static final GenericEntityProviderFactory instance =
      GenericEntityProviderFactory._privateConstructor();

  // Cache des providers par clé unique (ex: "SyncEntityNotifier<Chantier>::id123")
  final Map<String, dynamic> _providerCache = {};

  // --- SyncEntityNotifier Provider (exemple) ---
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

    final provider = StateNotifierProvider.autoDispose<
      SyncEntityNotifier<T>,
      SyncedState<T>
    >((ref) {
      final service = ref.read(entityServiceProvider<T>());
      final storage = ref.read(storageServiceProvider);

      final initialData = service.getById(id);
      if (initialData == null) {
        throw Exception('Entity with ID $id not found');
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

  // --- Exemple : Provider pour liste d'entités ---
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

      // Simple filtering exemple — à adapter selon besoins
      return all.where((item) {
        for (final entry in filter.entries) {
          final value = (item.toJson())[entry.key];
          if (value != entry.value) return false;
        }
        return true;
      }).toList();
    });

    _providerCache[key] = provider;
    return provider;
  }

  // --- Autres providers génériques peuvent être ajoutés ici ---

  // Clear cache (utile pour tests, reset)
  void clearCache() => _providerCache.clear();
}
