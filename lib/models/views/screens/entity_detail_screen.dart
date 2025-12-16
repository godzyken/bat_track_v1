import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../data/core/unified_model.dart';
import '../../data/adapter/typedefs.dart';
import '../../providers/asynchrones/entity_notifier_provider.dart';

class EntityDetailScreen<T extends UnifiedModel> extends ConsumerWidget {
  final EntityNotifierProviderFamily<T> providerFamily;
  final String id;
  final String title;
  final EntityDetailBuilder<T> builder;

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

    return switch (state) {
      AsyncData<T>(value: final entity) when entity.id == id => PopScope(
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop) await Future.value(notifier.arg);
        },
        child: Scaffold(
          appBar: AppBar(title: Text(title)),
          body: builder(context, entity, notifier, state),
        ),
      ),
      AsyncLoading() => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      AsyncError(:final error, :final stackTrace) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Center(child: Text('Erreur: $error')),
      ),
      // Gère le cas où l'entité est AsyncData(value: null)
      AsyncData(value: null) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: const Center(child: Text('Entité non trouvée')),
      ),
      _ => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: const Center(child: CircularProgressIndicator()),
      ),
    };
  }
}

class JsonModelRouter {
  static void navigateToDetail<T extends UnifiedModel>(
    BuildContext context,
    T entity,
  ) {
    final entityType = T.toString().toLowerCase();
    final id = entity.id;

    final routeName = '$entityType-detail'; // ex: chantier-detail
    context.goNamed(routeName, pathParameters: {'id': id}, extra: entity);
  }
}
