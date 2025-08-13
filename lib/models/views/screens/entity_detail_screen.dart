import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/adapter/typedefs.dart';
import '../../data/json_model.dart';
import '../../data/state_wrapper/wrappers.dart';
import '../../providers/synchrones/sync_entity_notifier_provider.dart';

class EntityDetailScreen<T extends JsonModel> extends ConsumerWidget {
  final String id;
  final String title;
  final EntityDetailBuilder<T> builder;

  const EntityDetailScreen({
    super.key,
    required this.id,
    required this.title,
    required this.builder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = GenericEntityProviderFactory.instance
        .getSyncEntityNotifierProvider<T>(id);
    final state = ref.watch(provider);
    final notifier = ref.read(provider.notifier);

    return switch (state) {
      SyncedState<T>(data: final entity) => PopScope(
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop) await notifier.syncNow();
        },
        child: Scaffold(
          appBar: AppBar(title: Text(title)),
          body: builder(context, entity, notifier, state),
        ),
      ),
    };
  }
}

class JsonModelRouter {
  static void navigateToDetail<T extends JsonModel>(
    BuildContext context,
    T entity,
  ) {
    final entityType = T.toString().toLowerCase();
    final id = entity.id;

    final routeName = '$entityType-detail'; // ex: chantier-detail
    context.goNamed(routeName, pathParameters: {'id': id}, extra: entity);
  }
}
