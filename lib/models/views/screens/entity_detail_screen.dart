import 'package:bat_track_v1/models/data/hive_model.dart';
import 'package:bat_track_v1/models/data/state_wrapper/wrappers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/core/unified_model.dart';
import '../../data/adapter/typedefs.dart';
import '../../providers/asynchrones/entity_notifier_provider.dart';

class EntityDetailScreen<T extends UnifiedModel, N extends HiveModel<T>>
    extends ConsumerWidget {
  final EntityNotifierProviderFamily<T, N> providerFamily;
  final String id;
  final String title;
  final EntityDetailBuilder<T, N> builder;

  const EntityDetailScreen({
    super.key,
    required this.providerFamily,
    required this.id,
    required this.title,
    required this.builder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = providerFamily(id);
    final state = ref.watch(provider);
    final notifier = ref.read(provider.notifier);

    return state.when(
      data: (entity) {
        if (entity == null || entity.id != id) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Non trouvé')),
          );
        }
        // Ici notifier est bien un SyncEntityNotifier<T, N>
        return Scaffold(
          appBar: AppBar(title: Text(title)),
          body: builder(context, entity, notifier, state as SyncedState<T>),
        );
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, st) => Scaffold(body: Center(child: Text('Erreur: $e'))),
    );
  }
}

class JsonModelRouter {
  static void navigateToDetail<T extends UnifiedModel>(
    BuildContext context,
    T entity,
    String routePrefix,
  ) {
    final id = entity.id;

    final routeName = '$routePrefix-detail'; // ex: chantier-detail
    context.goNamed(routeName, pathParameters: {'id': id}, extra: entity);
  }
}
